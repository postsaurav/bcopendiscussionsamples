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

    procedure UploadFileToSharepoint(FolderPath: Text; FileName: Text; Stream: InStream) DownloadURL: Text
    var
        JsonResponse: JsonObject;
        JToken: JsonToken;
        PassedURL: Text;
        UploadUrl: Label 'https://graph.microsoft.com/v1.0/sites/%1/drives/%2/items/%3:/%4:/content';
        FilePath: Label '%1/%2';
    begin
        ClearAndInitVariables();
        PassedURL := StrSubstNo(UploadUrl, SharepointSetup."Site id", SharepointSetup."Document Libarary id", SharepointSetup."Document Folder id", StrSubstNo(FilePath, FolderPath, FileName));
        HttpRequestType := HttpRequestType::PUT;

        if CallGraphAPI(PassedURL, JsonResponse, Stream) then;
        if JsonResponse.GET('@microsoft.graph.downloadUrl', JToken) then
            DownloadURL := JToken.AsValue().AsText();
    end;

    procedure DownloadFileFromSharepoint(FileName: Text; Var Stream: InStream) fieldownload: Boolean
    var
        SharepointDisc: Dictionary of [Text, Text];
        PassedURL: Text;
        JsonResponse: JsonObject;
        JToken: JsonToken;
        DownloadURL: Label 'https://graph.microsoft.com/v1.0/sites/%1/drives/%2/items/%3/children';
    begin
        ClearAndInitVariables();
        PassedURL := StrSubstNo(DownloadURL, SharepointSetup."Site id", SharepointSetup."Document Libarary id", SharepointSetup."Document Folder id");
        HttpRequestType := HttpRequestType::GET;
        CallGraphAPI(PassedURL, JsonResponse);

        if JsonResponse.Get('value', JToken) then
            ReadJsonResponse(JToken, SharepointDisc);

        HttpRequestType := HttpRequestType::GET;

        if CallGraphAPI(SharepointDisc.GET(FileName), JsonResponse, Stream) = true then
            fieldownload := true;
    end;

    local procedure ReadJsonResponse(JToken: JsonToken; Var SharepointDisc: Dictionary of [Text, Text])
    var
        SharepointArray: JsonArray;
        JSingleToken: JsonToken;
        Jobject: JsonObject;
        Filename: Text;
        DownloadURL: Text;
    begin
        SharepointArray := JToken.AsArray();

        foreach JSingleToken in SharepointArray do begin
            Jobject := JSingleToken.AsObject();

            if Jobject.Get('name', JToken) then
                Filename := JToken.AsValue().AsText();
            if Jobject.Get('@microsoft.graph.downloadUrl', JToken) then
                DownloadURL := JToken.AsValue().AsText();

            SharepointDisc.Add(Filename, DownloadURL);
        end;
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

    local procedure CallGraphAPI(PassedURL: Text; var JsonResponse: JsonObject; Var Stream: InStream): Boolean
    var
        HttpClientSharePoint: HttpClient;
        Headers: HttpHeaders;
        HttpResponseMessageSharePoint: HttpResponseMessage;
        HttpRequestMessageSharePoint: HttpRequestMessage;
        RequestContent: HttpContent;
        ResponseText: Text;
    begin
        Headers := HttpClientSharePoint.DefaultRequestHeaders();
        Headers.Add('Authorization', StrSubstNo(BearerLbl, SharepointSetup.GetAccessToken()));
        HttpRequestMessageSharePoint.SetRequestUri(passedURL);

        Case HttpRequestType Of
            HttpRequestType::GET:
                HttpRequestMessageSharePoint.Method := 'GET';
            HttpRequestType::PUT:
                begin
                    HttpRequestMessageSharePoint.Method := 'PUT';
                    RequestContent.WriteFrom(Stream);
                    HttpRequestMessageSharePoint.Content := RequestContent;
                end;
        End;

        if HttpClientSharePoint.Send(HttpRequestMessageSharePoint, HttpResponseMessageSharePoint) then
            if HttpResponseMessageSharePoint.IsSuccessStatusCode() then begin

                if HttpRequestType = HttpRequestType::GET then
                    HttpResponseMessageSharePoint.Content.ReadAs(Stream)
                else
                    if HttpResponseMessageSharePoint.Content.ReadAs(ResponseText) then
                        JsonResponse.ReadFrom(ResponseText);
                exit(true);
            end else
                exit(false);
    end;

    procedure AddRecordLink(PassedRecordID: RecordId; PassedFilename: Text[250]; PassedDownloadURL: Text[2048])
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.Init();
        RecordLink."Record ID" := PassedRecordID;
        RecordLink.Description := PassedFilename;
        RecordLink.URL1 := PassedDownloadURL;
        RecordLink.Type := RecordLink.Type::Link;
        
        RecordLink.Created := CurrentDateTime();
        RecordLink."User ID" := UserId();
        RecordLink.Company := CompanyName();
        RecordLink.Insert(true);
    end;

    var
        SharepointSetup: Record "BOD Sharepoint Setup";
        HttpRequestType: Enum "Http Request Type";
        BearerLbl: Label 'Bearer %1', Comment = '%1 Access Token';
        ErrorStatusLbl: Label 'Unable to Access URL with Status Code %1 ', Comment = '%1 Error Code.';
}