codeunit 50001 "BOD Sharepoint Mgmt."
{
    procedure GetSharepointID(PassedURL: Text; var ReturnSharepointName: Text; var ReturnSharepointId: Text)
    var
        JsonResponse: JsonObject;
        JToken: JsonToken;
    begin
        ClearAndInitVariables();
        HttpRequestType := HttpRequestType::GET;
        CallGraphAPI(PassedURL, JsonResponse);

        if not JsonResponse.Contains('value') then
            Error('Invalid Response.');

        if JsonResponse.GET('value', JToken) then
            ReadJsonResponse(JToken, ReturnSharepointName, ReturnSharepointId);
    end;

    local procedure ReadJsonResponse(JToken: JsonToken; var ReturnSharepointName: Text; var ReturnSharepointId: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        JArray: JsonArray;
        RecordFound: Integer;
    begin
        JArray := JToken.AsArray();
        RecordFound := GenerateLookupData(JArray, TempNameValueBuffer);

        if not TempNameValueBuffer.FindFirst() then
            error('No Record Found.');

        if RecordFound = 1 then begin
            ReturnSharepointId := TempNameValueBuffer.Name;
            ReturnSharepointName := TempNameValueBuffer.Value;
        end else
            if PAGE.RunModal(PAGE::"Name/Value Lookup", TempNameValueBuffer) = ACTION::LookupOK then begin
                ReturnSharepointId := TempNameValueBuffer.Name;
                ReturnSharepointName := TempNameValueBuffer.Value;
            end;
    end;

    local procedure GenerateLookupData(JArraySource: JsonArray; var TempNameValueBufferOut: Record "Name/Value Buffer" temporary) RecordFound: Integer
    var
        JSingleToken: JsonToken;
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        foreach JSingleToken in JArraySource do begin
            RecordFound += 1;
            JObject := JSingleToken.AsObject();

            if JObject.Get('name', JToken) then begin
                TempNameValueBufferOut.Init();
                TempNameValueBufferOut.ID := RecordFound;
                if JObject.Get('id', JToken) then
                    TempNameValueBufferOut.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempNameValueBufferOut.Name));
                if JObject.Get('name', JToken) then
                    TempNameValueBufferOut.Value := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempNameValueBufferOut.Value));
                TempNameValueBufferOut.Insert();
            end;
        end;
    end;

    local procedure ClearAndInitVariables()
    begin
        clear(HttpRequestType);
        SharepointSetup.Get();
    end;

    local procedure CallGraphAPI(PassedURL: Text; var JsonResponse: JsonObject)
    var
        HttpClientSharePoint: HttpClient;
        Headers: HttpHeaders;
        HttpResponseMessageSharePoint: HttpResponseMessage;
        HttpRequestMessageSharePoint: HttpRequestMessage;
        ResponseText: Text;
    begin
        Headers := HttpClientSharePoint.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo(BearerLbl, SharepointSetup.GetAccessToken()));
        HttpRequestMessageSharePoint.SetRequestUri(passedURL);

        Case HttpRequestType Of
            HttpRequestType::GET:
                HttpRequestMessageSharePoint.Method := 'GET';
        End;

        if HttpClientSharePoint.Send(HttpRequestMessageSharePoint, HttpResponseMessageSharePoint) then
            if HttpResponseMessageSharePoint.IsSuccessStatusCode() then begin
                if HttpResponseMessageSharePoint.Content.ReadAs(ResponseText) then
                    JsonResponse.ReadFrom(ResponseText);
            end else
                error(ErrorStatusLbl, HttpResponseMessageSharePoint.HttpStatusCode);
    end;

    var
        SharepointSetup: Record "BOD Sharepoint Setup";
        HttpRequestType: Enum "Http Request Type";
        BearerLbl: Label 'Bearer %1', Comment = '%1 Access Token';
        ErrorStatusLbl: Label 'Unable to Access URL with Status Code %1 ', Comment = '%1 Error Code.';
}