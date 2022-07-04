unit SE.UpdateManager;

interface

uses System.Classes, System.SysUtils, System.Net.HttpClientComponent,
  System.Net.HttpClient, System.Net.URLClient, Generics.Collections;

const
  hdr_ifmodmatch = 'If-Modified-Since';
  hdr_lastmodified = 'Last-Modified';

type
  TSEUrlCacheEntry = class;
  TSEUrlCacheRefreshDone = procedure(AMessage: string; ACacheEntry: TSEUrlCacheEntry) of object;

  TSEUrlCacheManagerMessage = procedure(AMessage: string) of object;

  TSEUrlCacheEntry = class
  const
    dt_lastmod_default = 'Fri, 01 Apr 2010 23:15:56 GMT';
    nm_json_object = 'UrlCacheEntry';
    nm_json_prop_url = 'URL';
    nm_json_prop_lastmod = 'LastModified';
    nm_json_prop_refreshdts = 'RefreshDts';
    nm_json_prop_cacheagesec = 'CacheAgeSec';
    nm_json_prop_extractzip = 'ExtractZip';
    nm_json_prop_extractpath = 'ExtractPath';
    def_cacheagesec = 60;
  strict private
    FMREW: TMultiReadExclusiveWriteSynchronizer;
    FLastModified: string;
    FURL: string;
    FRefreshDts: TDateTime;
    FLocalPath, FExtractPath: string;
    FExtractZip: boolean;
    FCacheAgeSeconds: integer;
    FLastHttpCode: integer;
    FHTTPRequest: TNetHTTPRequest;
    FCacheMgrMsg: TSEUrlCacheManagerMessage;
    FOnRefreshDone: TSEUrlCacheRefreshDone;
  strict private
    function LastModifiedGet: string;
    procedure LastModifiedSet(const Value: string);
    function URLGet: string;
    procedure URLSet(const Value: string);
    function RefreshDtsGet: TDateTime;
    procedure RefreshDtsSet(const Value: TDateTime);
    function LocalPathGet: string;
    procedure LocalPathSet(const Value: string);
    procedure DownloadUrl;
    procedure LogMessage(AMessage: string);
    function CacheAgeSecondsGet: integer;
    procedure CacheAgeSecondsSet(const Value: integer);
    procedure HttpException(const Sender: TObject; const AError: Exception);
    procedure HttpCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    function ExtractPathGet: string;
    procedure ExtractPathSet(const Value: string);
    function ExtractZipGet: boolean;
    procedure ExtractZipSet(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property LastModified: string read LastModifiedGet write LastModifiedSet;
    property URL: string read URLGet write URLSet;
    property RefreshDts: TDateTime read RefreshDtsGet write RefreshDtsSet;
    property LocalPath: string read LocalPathGet write LocalPathSet;
    property CacheAgeSeconds: integer read CacheAgeSecondsGet write CacheAgeSecondsSet;
    function LocalFileExists: boolean;
    procedure RefreshCache;
    procedure AssignHttpClient(AHttpClient: TNetHTTPClient);
    property OnRequestMessage: TSEUrlCacheManagerMessage read FCacheMgrMsg write FCacheMgrMsg;
    property OnRefreshDone: TSEUrlCacheRefreshDone read FOnRefreshDone write FOnRefreshDone;
    property ExtractZip: boolean read ExtractZipGet write ExtractZipSet;
    property ExtractPath: string read ExtractPathGet write ExtractPathSet;
    property LastHttpCode:integer read FLastHttpCode write FLastHttpCode;
  end;

  TSEUrlCacheManager = class

  const
    nm_json_object = 'UrlCacheManager';
    nm_json_prop_caches = 'caches';
  strict private
    FMREW: TMultiReadExclusiveWriteSynchronizer;
    FCaches: TObjectDictionary<string, TSEUrlCacheEntry>;
    // FRequests: TObjectDictionary<TNetHTTPRequest, TUrlCacheEntry>;
    FHTTPClient: TNetHTTPClient;
    FCacheMgrMsg: TSEUrlCacheManagerMessage;
    procedure InitHttpClient;
    function CachesGet: TObjectDictionary<string, TSEUrlCacheEntry>;
    procedure CachesSet(const Value: TObjectDictionary<string, TSEUrlCacheEntry>);
    function JsonStringGet: string;
    procedure JsonStringSet(const Value: string);
    procedure LogMessage(AMessage: string);
    procedure HttpClientException(const Sender: TObject; const AError: Exception);
    procedure DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType; const ARealm, AURL: string;
      var AUserName, APassword: string; var AbortAuth: boolean; var Persistence: TAuthPersistenceType);
    function HttpClientGet: TNetHTTPClient;
  private
    property HttpClient: TNetHTTPClient read HttpClientGet;
  public
    KeyName: string;
    constructor Create;
    destructor Destroy; override;
    function CacheByUrl(AHttpUrl: string): TSEUrlCacheEntry;
    property Caches: TObjectDictionary<string, TSEUrlCacheEntry> read CachesGet write CachesSet;
    property JsonString: string read JsonStringGet write JsonStringSet;
    property OnManagerMessage: TSEUrlCacheManagerMessage read FCacheMgrMsg write FCacheMgrMsg;
//    property LastRefreshDate: TDateTime read FLastRefreshDate write FLastRefreshDate;
  end;

implementation

uses System.Zip, DateUtils, System.IOUtils, System.JSON, System.JSON.Writers, System.JSON.Types;

{ TUrlCacheEntry }

procedure TSEUrlCacheEntry.AssignHttpClient(AHttpClient: TNetHTTPClient);
begin
  FHTTPRequest := TNetHTTPRequest.Create(nil);
  FHTTPRequest.Client := AHttpClient;
end;

function TSEUrlCacheEntry.CacheAgeSecondsGet: integer;
begin
  FMREW.BeginRead;
  result := FCacheAgeSeconds;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.CacheAgeSecondsSet(const Value: integer);
begin
  FMREW.BeginWrite;
  FCacheAgeSeconds := Value;
  FMREW.EndWrite;
end;

constructor TSEUrlCacheEntry.Create;
begin
  FMREW := TMultiReadExclusiveWriteSynchronizer.Create;
  CacheAgeSeconds := def_cacheagesec;
end;

destructor TSEUrlCacheEntry.Destroy;
begin
  FHTTPRequest.Free;
  FMREW.Free;
  inherited;
end;

procedure TSEUrlCacheEntry.DownloadUrl;
begin
  if not Assigned(FHTTPRequest) then // FHTTPRequest.Client
    LogMessage('client not assigned');
  FHTTPRequest.OnRequestException := HttpException;
  FHTTPRequest.SynchronizeEvents := false;
  FHTTPRequest.OnRequestCompleted := HttpCompleted;
  FHTTPRequest.Asynchronous := true;
  FHTTPRequest.CustomHeaders[hdr_ifmodmatch] := LastModified; // .Replace('2022', '2021');
  FHTTPRequest.Get(URL);
end;

function TSEUrlCacheEntry.ExtractPathGet: string;
begin
  FMREW.BeginRead;
  result := FExtractPath;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.ExtractPathSet(const Value: string);
begin
  FMREW.BeginWrite;
  FExtractPath := Value;
  FMREW.EndWrite;
end;

function TSEUrlCacheEntry.ExtractZipGet: boolean;
begin
  FMREW.BeginRead;
  result := FExtractZip;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.ExtractZipSet(const Value: boolean);
begin
  FMREW.BeginWrite;
  FExtractZip := Value;
  FMREW.EndWrite;
end;

procedure TSEUrlCacheEntry.HttpCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  lfs: TFileStream;
begin
  LastHttpCode:=         AResponse.StatusCode;
  if AResponse.StatusCode = 200 then
  begin
    LastModified := AResponse.HeaderValue[hdr_lastmodified];
    RefreshDts := now;
    lfs := TFileStream.Create(LocalPath, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting Deputy Experts');
    if ExtractZip then
    begin
      if TZipFile.IsValid(LocalPath) then
      begin
        LogMessage('Zip File is valid ' + LocalPath);
        TZipFile.ExtractZipFile(LocalPath, ExtractPath);
        LogMessage('Wizard Updates Extracted.');
      end
      else // Zip file invalid
        LogMessage('Zip File not valid ' + LocalPath);
    end
  end
  else if AResponse.StatusCode = 304 then
  begin
    RefreshDts := now;
    LogMessage('File not modified Http result = ' + AResponse.StatusCode.ToString);
  end
  else
    LogMessage('URL Cache Http result = ' + AResponse.StatusCode.ToString);
  if Assigned(OnRefreshDone) then
    OnRefreshDone('all done', self);
end;

procedure TSEUrlCacheEntry.HttpException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'UrlCache~Http Server Exception:' + AError.Message;
  LogMessage(msg);
end;

function TSEUrlCacheEntry.LastModifiedGet: string;
begin
  FMREW.BeginRead;
  result := FLastModified;
  if result.length = 0 then // Header can not be added as null
    result := dt_lastmod_default;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.LastModifiedSet(const Value: string);
begin
  FMREW.BeginWrite;
  FLastModified := Value;
  FMREW.EndWrite;
end;

function TSEUrlCacheEntry.LocalFileExists: boolean;
begin
  result := TFile.exists(LocalPath);
end;

function TSEUrlCacheEntry.LocalPathGet: string;
begin
  FMREW.BeginRead;
  result := FLocalPath;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.LocalPathSet(const Value: string);
begin
  FMREW.BeginWrite;
  FLocalPath := Value;
  FMREW.EndWrite;
end;

procedure TSEUrlCacheEntry.LogMessage(AMessage: string);
begin
  if Assigned(OnRequestMessage) then
    OnRequestMessage(AMessage);
end;

procedure TSEUrlCacheEntry.RefreshCache;
begin
  LogMessage('Refreshing cache of ' + self.URL);
  if (SecondsBetween(RefreshDts, now) > CacheAgeSeconds) or not LocalFileExists then
    DownloadUrl
end;

function TSEUrlCacheEntry.RefreshDtsGet: TDateTime;
begin
  FMREW.BeginRead;
  result := FRefreshDts;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.RefreshDtsSet(const Value: TDateTime);
begin
  FMREW.BeginWrite;
  FRefreshDts := Value;
  FMREW.EndWrite;
end;

function TSEUrlCacheEntry.URLGet: string;
begin
  FMREW.BeginRead;
  result := FURL;
  FMREW.EndRead;
end;

procedure TSEUrlCacheEntry.URLSet(const Value: string);
begin
  FMREW.BeginWrite;
  FURL := Value;
  FMREW.EndWrite;
end;

{ TSEUrlCacheManager }

function TSEUrlCacheManager.CacheByUrl(AHttpUrl: string): TSEUrlCacheEntry;
var
  b: boolean;
begin
  FMREW.BeginRead;
  b := Caches.TryGetValue(AHttpUrl, result);
  FMREW.EndRead;
  if not b then
  begin
    FMREW.BeginWrite;
    result := TSEUrlCacheEntry.Create;
    result.OnRequestMessage := LogMessage;
    result.URL := AHttpUrl;
    result.AssignHttpClient(HttpClient);
    Caches.Add(AHttpUrl, result);
    FMREW.EndWrite;
  end;
end;

function TSEUrlCacheManager.CachesGet: TObjectDictionary<string, TSEUrlCacheEntry>;
begin
  FMREW.BeginRead;
  result := FCaches;
  FMREW.EndRead;
end;

procedure TSEUrlCacheManager.CachesSet(const Value: TObjectDictionary<string, TSEUrlCacheEntry>);
begin
  FMREW.BeginWrite;
  FCaches := Value;
  FMREW.EndWrite;
end;

constructor TSEUrlCacheManager.Create;
begin
  FMREW := TMultiReadExclusiveWriteSynchronizer.Create;
  FCaches := TObjectDictionary<string, TSEUrlCacheEntry>.Create([doOwnsValues]);
end;

destructor TSEUrlCacheManager.Destroy;
begin
  FMREW.Free;
  FCaches.Free;
  FHTTPClient.Free;
  inherited;
end;

procedure TSEUrlCacheManager.DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType;
  const ARealm, AURL: string; var AUserName, APassword: string; var AbortAuth: boolean;
  var Persistence: TAuthPersistenceType);
begin
  if AnAuthTarget = TAuthTargetType.Server then
  begin
    AUserName := 'DeputyExpert';
    APassword := 'Illbeyourhuckleberry';
  end;
end;

procedure TSEUrlCacheManager.HttpClientException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Cache Manager~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

function TSEUrlCacheManager.HttpClientGet: TNetHTTPClient;
begin
  InitHttpClient;
  FMREW.BeginRead;
  result := FHTTPClient;
  FMREW.EndRead;
end;

procedure TSEUrlCacheManager.InitHttpClient;
begin
  if not Assigned(FHTTPClient) then
  begin
    FMREW.BeginWrite;
    FHTTPClient := TNetHTTPClient.Create(nil);
    FHTTPClient.OnAuthEvent := DistServerAuthEvent;
{$IF COMPILERVERSION > 33}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
    FHTTPClient.OnRequestException := HttpClientException;
    FHTTPClient.UseDefaultCredentials := false;
{$ELSEIF COMPILERVERSION = 33}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
{$ENDIF}
    // FHTTPClient.UserAgent := nm_user_agent;
    { TODO : Create a hash of Username / Computer name }
    FMREW.EndWrite;
  end;
end;

function TSEUrlCacheManager.JsonStringGet: string;
var // code here to get the string for the registry
  Writer: TJsonTextWriter;
  StringWriter: TStringWriter;
  ce: TSEUrlCacheEntry;
begin
  StringWriter := TStringWriter.Create();
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.None; // compact it for registry
  Writer.WriteStartObject;
  Writer.WritePropertyName(nm_json_prop_caches);
  Writer.WriteStartArray;
  for ce in Caches.Values do
  begin
    Writer.WriteStartObject;
    Writer.WritePropertyName(ce.nm_json_prop_url);
    Writer.WriteValue(ce.URL);
    Writer.WritePropertyName(ce.nm_json_prop_lastmod);
    Writer.WriteValue(ce.LastModified);
    Writer.WritePropertyName(ce.nm_json_prop_refreshdts);
    Writer.WriteValue(DateToISO8601(ce.RefreshDts, false));
    Writer.WritePropertyName(ce.nm_json_prop_cacheagesec);
    Writer.WriteValue(ce.CacheAgeSeconds);
    Writer.WritePropertyName(ce.nm_json_prop_extractzip);
    Writer.WriteValue(booltostr(ce.ExtractZip, false));
    Writer.WritePropertyName(ce.nm_json_prop_extractpath);
    Writer.WriteValue(ce.ExtractPath);
    Writer.WriteEndObject;
  end;
  Writer.WriteEndArray;
  Writer.WriteEndObject;
  result := StringWriter.ToString;
  Writer.Free;
  StringWriter.Free;
end;

procedure TSEUrlCacheManager.JsonStringSet(const Value: string);
var
  JSONValue: TJSONValue;
  Caches: TJSONArray;
  I: integer;
  ce: TSEUrlCacheEntry;
  jo: TJSONObject;
begin // load Caches from string
  JSONValue := TJSONObject.ParseJSONValue(Value);
  try
    if not(JSONValue is TJSONObject) then
      exit;
    if JSONValue.TryGetValue<TJSONArray>(nm_json_prop_caches, Caches) then
    begin
      FCaches.Free;
      FCaches := TObjectDictionary<string, TSEUrlCacheEntry>.Create([doOwnsValues]);
      for I := 0 to Caches.Count - 1 do
      begin
        jo := Caches[I] as TJSONObject;
        ce := TSEUrlCacheEntry.Create;
        ce.URL := jo.GetValue<string>(ce.nm_json_prop_url, 'https://localhost');
        ce.LastModified := jo.GetValue<string>(ce.nm_json_prop_lastmod, ce.dt_lastmod_default);
        ce.RefreshDts := ISO8601ToDate(jo.GetValue<string>(ce.nm_json_prop_refreshdts,
          DateToISO8601(now, false)), false);
        ce.CacheAgeSeconds := jo.GetValue<integer>(ce.nm_json_prop_cacheagesec, ce.def_cacheagesec);
        ce.ExtractZip := StrToBool(jo.GetValue<string>(ce.nm_json_prop_extractzip, '0'));
        ce.ExtractPath := jo.GetValue<string>(ce.nm_json_prop_extractpath, TPath.GetTempPath);
        ce.AssignHttpClient(HttpClient);
        FCaches.Add(ce.URL, ce);
      end;
    end
    else
      raise Exception.Create('Caches not found');
  finally
    JSONValue.Free;
  end;
end;

procedure TSEUrlCacheManager.LogMessage(AMessage: string);
begin
  if Assigned(OnManagerMessage) then
    OnManagerMessage(AMessage);
end;

end.
