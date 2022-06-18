codeunit 50001 "BOD Sharepoint Mgmt."
{
    procedure GetSharepointID(PassedURL: Text; var SiteID: Text)
    var
        SharepointSetup: Record "BOD Sharepoint Setup";
        HttpClientSP: HttpClient;
        Headers: HttpHeaders;
        HttpRequestMessageSP: HttpRequestMessage;
        HttpResponseMessageSP: HttpResponseMessage;
        ResponseText: Text;
        JsonResponse: JsonObject;
        JToken: JsonToken;
        ErrorStatusTxt: Label 'Unable to Access URL. Error Status Code is %1', Comment = '%1 Status Code';
        BearerLbl: Label 'Bearer %1', Comment = '%1 Access Token';
    begin
        Headers := HttpClientSP.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo(BearerLbl, SharepointSetup.GetAccessToken()));
        HttpRequestMessageSP.SetRequestUri(PassedURL);
        HttpRequestMessageSP.Method := 'GET';

        if HttpClientSP.Send(HttpRequestMessageSP, HttpResponseMessageSP) then
            if HttpResponseMessageSP.IsSuccessStatusCode() then begin
                if HttpResponseMessageSP.Content.ReadAs(ResponseText) then
                    JsonResponse.ReadFrom(ResponseText);
                JsonResponse.Get('id', JToken);
                SiteID := JToken.AsValue().AsText();
            end else
                error(ErrorStatusTxt, HttpResponseMessageSP.HttpStatusCode);
    end;

    procedure GetDriveID(PassedURL: Text; var DriveName: Text; var DriveID: Text)
    var
        SharepointSetup: Record "BOD Sharepoint Setup";
        HttpClientSP: HttpClient;
        Headers: HttpHeaders;
        HttpRequestMessageSP: HttpRequestMessage;
        HttpResponseMessageSP: HttpResponseMessage;
        ResponseText: Text;
        JsonResponse: JsonObject;
        JToken: JsonToken;
        ErrorStatusTxt: Label 'Unable to Access URL. Error Status Code is %1', Comment = '%1 Status Code';
        BearerLbl: Label 'Bearer %1', Comment = '%1 Access Token';
    begin
        Headers := HttpClientSP.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo(BearerLbl, SharepointSetup.GetAccessToken()));
        HttpRequestMessageSP.SetRequestUri(PassedURL);
        HttpRequestMessageSP.Method := 'GET';

        if HttpClientSP.Send(HttpRequestMessageSP, HttpResponseMessageSP) then
            if HttpResponseMessageSP.IsSuccessStatusCode() then begin
                if HttpResponseMessageSP.Content.ReadAs(ResponseText) then
                    JsonResponse.ReadFrom(ResponseText);

                if not JsonResponse.Contains('value') then
                    error('Invaild Response');

                if JsonResponse.Get('value', JToken) then
                    ReadJsonResponse(JToken, DriveName, DriveID);

            end else
                error(ErrorStatusTxt, HttpResponseMessageSP.HttpStatusCode);
    end;

    local procedure ReadJsonResponse(JToken: JsonToken; var DriveName: Text; var DriveID: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        JArray: JsonArray;
        JSingleToken: JsonToken;
        JObject: JsonObject;
        ResponseToken: JsonToken;
        RecordCnt: Integer;
    begin
        JArray := JToken.AsArray();

        foreach JSingleToken in JArray do begin
            JObject := JSingleToken.AsObject();
            RecordCnt += 1;

            if JObject.Get('name', ResponseToken) then begin
                TempNameValueBuffer.Init();
                TempNameValueBuffer.ID := RecordCnt;
                TempNameValueBuffer.Name := ResponseToken.AsValue().AsText();
            end;
            if JObject.GET('id', ResponseToken) then
                TempNameValueBuffer.Value := ResponseToken.AsValue().AsText();
            TempNameValueBuffer.Insert();
        end;

        TempNameValueBuffer.FindFirst();

        if RecordCnt = 1 then begin
            DriveName := TempNameValueBuffer.Name;
            DriveID := TempNameValueBuffer.Value;
        end else
            if Page.RunModal(page::"Name/Value Lookup", TempNameValueBuffer) = Action::LookupOK then begin
                DriveName := TempNameValueBuffer.Name;
                DriveID := TempNameValueBuffer.Value;
            end;
    end;
}