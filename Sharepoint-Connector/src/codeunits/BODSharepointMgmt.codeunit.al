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
                    //JsonResponse.ReadFrom(ResponseText);
                    Message('%1', ResponseText);
            end else
                error(ErrorStatusTxt, HttpResponseMessageSP.HttpStatusCode);
    end;
}