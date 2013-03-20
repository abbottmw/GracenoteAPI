component  output="false" accessors="true"
{
	property name="url"  type="string" required="true";
	property name="clientId"  type="string" required="true";
	property name="userId"  type="string" required="true";
	  
	Gracenote function init(Required String clientId, String userId=""){
		var local = {};
		setClientId(ARGUMENTS.clientId);
		
		if( !isNull( ARGUMENTS.userId ) && len( trim( ARGUMENTS.userId ) )){
			setUserId( ARGUMENTS.userId );
		}
		
		local.cID = ListFirst( getClientId() ,'-');
		setURL( 'https://c' & local.cID & '.web.cddbp.net/webapi/xml/1.0/' );
		return this;
	}
	
	public function register(){
		var cmdString = '<QUERIES><QUERY CMD="REGISTER"><CLIENT>' & getClientId() & '</CLIENT></QUERY></QUERIES>';
		var result = "";
		var user = "";
		
		if( !Len( getUserId() ) ){
			
			result = send(cmdString);

			if(isXML( result )){
				user = xmlSearch(result,'//USER');
				if(ArrayLen(user)){
					user = user[1].xmlText;
					setUserId(user);
				}else{
					user = "";
				}
			}
			
		}else{
			user = getUserId();
		}
		
		
		return user;
	}
	
	
	private any function send(String cmd){
		
		
		var http = new http();
		var result = {};
		http.setUrl(getURL());
		http.setMethod('POST');
		http.setThrowOnError(true);
		http.addParam(type="header",name="Content-Type",value="text/xml");
		http.addParam(type='header',name="User-Agent",value="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0)");
		http.addParam(type="body",value=Trim(ARGUMENTS.cmd));
		
		
		result = http.send().getPrefix();
		
		checkResponse(result.fileContent);
		
		return isXML(result.fileContent)? XMLParse(result.fileContent) : result.fileContent;
		
		
	}
	
	public any function albumSearch(String artist = "",String albumtitle="",String tracktitle=""){
		
		var body = constructBody(ARGUMENTS.artist,ARGUMENTS.albumtitle,ARGUMENTS.tracktitle);
		var data = constructRequest(body);
		return send(data);
		
	}
	
	public any function fetchByID(String gn_id){
		
		
		var body = constructBody("","","",ARGUMENTS.gn_id,"ALBUM_FETCH");
		var data = constructRequest(body,"ALBUM_FETCH");
		return send(data);
	}
	
	
	public any function albumTOC(String toc=""){
		
		var body = "<TOC><OFFSETS>" & ARGUMENTS.toc & "</OFFSETS></TOC>";
		var data = constructRequest(body,"ALBUM_TOC");
		return send(data);
		
	}

	private string function constructRequest(String body="",String command="ALBUM_SEARCH"){
		
		var qString = "";
		qString &= "<QUERIES>";
		qString &= "<AUTH>";
		qString &= "<CLIENT>" & getClientId() & "</CLIENT>";
		qString &= "<USER>" & getUserId() & "</USER>";
		qString &= "</AUTH>";
		qString &= '<QUERY CMD="' & ARGUMENTS.command & '">' & ARGUMENTS.body & "</QUERY>";
	
		
		qString &= "</QUERIES>";
		
		return qString;
		
	}
	
	private string function constructBody(String artist="", String album = "", String track = "", String gn_id = "", String command=""){
		var body = "";
		
		
		switch(ARGUMENTS.command){
			case 'ALBUM_FETCH' :
			
				body &= "<GN_ID>" & ARGUMENTS.gn_id & "</GN_ID>";
				break;
				
			default:
				
			body &= "<MODE>SINGLE_BEST_COVER</MODE>";
			
			if(len(trim(ARGUMENTS.artist))){ 
				body &= '<TEXT TYPE="ARTIST">' & ARGUMENTS.artist & '</TEXT>';
			}
			
			if(len(trim(ARGUMENTS.album))){ 
				body &= '<TEXT TYPE="ALBUM_TITLE">' & ARGUMENTS.album & '</TEXT>';
			}
			
			if(len(trim(ARGUMENTS.track))){ 
				body &= '<TEXT TYPE="TRACK_TITLE">' & ARGUMENTS.track & '</TEXT>';
			}
			
			
			body &= "<OPTION>";
			body &= "<PARAMETER>SELECT_EXTENDED</PARAMETER>";
			body &= "<VALUE>COVER,REVIEW,ARTIST_BIOGRAPHY,ARTIST_IMAGE,ARTIST_OET,MOOD,TEMPO,URL</VALUE>";
			body &= "</OPTION>";
			
			body &= "<OPTION>";
			body &= "<PARAMETER>SELECT_DETAIL</PARAMETER>";
			body &= "<VALUE>GENRE:3LEVEL,MOOD:2LEVEL,TEMPO:3LEVEL,ARTIST_ORIGIN:4LEVEL,ARTIST_ERA:2LEVEL,ARTIST_TYPE:2LEVEL</VALUE>";
			body &= "</OPTION>";
				
			body &= "<OPTION>";
			body &= "<PARAMETER>COVER_SIZE</PARAMETER>";
			body &= "<VALUE>LARGE,XLARGE,SMALL,MEDIUM,THUMBNAIL</VALUE>";
			body &= "</OPTION>";
			
			break;
			
			
		}
		
		
		
		return body;
	}
	
	
	private void function checkResponse(Required String response){
		
		var xmlSearch = [];
		var status = 'OK';
		var message = "";
		
		if(isXML( ARGUMENTS.response )){
			
			xmlSearch = xmlSearch(ARGUMENTS.response,'//MESSAGE');
			
			if(arrayLen(xmlSearch)){
				message = xmlSearch[1].xmlText;	
			}
			
			
			xmlSearch = xmlSearch(ARGUMENTS.response,'//RESPONSE[@STATUS]');
			
			if(arrayLen(xmlSearch)){
				status = xmlSearch[1].xmlAttributes['status'];	
			}
			
		}
		
		switch(status){
			case 'ERROR' :
			throw(message="#message#");
			
			break;
			
			case 'NO_MATCH' :
			throw(message="No Match Found");
			break;
			
			default:
			
		}
		
		
		
	
	}
}