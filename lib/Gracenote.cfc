component  output="false" accessors="true"
{
	property name="url"  type="string" required="true";
	property name="clientId"  type="string" required="true";
	property name="id" type="string" required="false" hint="Client ID (everything from the start to the '-' in the clientId)" ;
	property name="tag" type="string" required="false" hint="Client Tag (everything after the '-' in the clientId)";
	property name="userId"  type="string" required="true";
	property name="returnType"  type="string" required="false" default="xml";
	
	/*
		Initial Constructor
		Pass in the Client id (XXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX).
		If you have a User ID, you can pass it in here.
	*/  
	Public Gracenote function init(Required String clientId, String userId, String returnType=""){
		var local = {};
		setClientId(ARGUMENTS.clientId);
		setID(ListFirst( getClientId() ,'-'));
		setTag(ListLast( getClientId() ,'-'));
		
		
		if( !isNull( ARGUMENTS.userId ) && len( trim( ARGUMENTS.userId ) )){
			setUserId( ARGUMENTS.userId );
		}
		
		if(ListFindNoCase('xml,json',trim(ARGUMENTS.returnType))){
			setReturnType(trim(ARGUMENTS.returnType));
		}else{
			setReturnType('xml');
		}
		
		local.cID = getID();
		setURL( 'https://c' & local.cID & '.web.cddbp.net/webapi/xml/1.0/' );
		return this;
	}
	
	/*
		Retrieves UserID from Gracenote WEB API.  Should be cached, called only once.
	*/
	public string function register(){
		var cmdString = '<QUERIES><QUERY CMD="REGISTER"><CLIENT>' & getClientId() & '</CLIENT></QUERY></QUERIES>';
		var result = "";
		var user = "";
		
		if( !Len( getUserId() ) ){
			
			result = send(cmdString, 'xml');

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
	
	
	/*
		Sends HTTP Request to Gracenote WEB API
		Needs output=false for http() call
	*/
	private any function send(String command, String returnType=getReturnType()) output=false{
		
		
		var http = new http();
		var result = {};
		var xmlStruct = {};

		http.setUrl(getURL());
		http.setMethod('POST');
		http.setThrowOnError(false);
		http.addParam(type="header",name="Content-Type",value="text/xml");
		http.addParam(type='header',name="User-Agent",value="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0)");
		http.addParam(type="body",value=Trim(ARGUMENTS.command));
		http.setTimeout(10);
		
		
		result = http.send().getPrefix();
		checkResponse(result.fileContent);
		
		
		switch(LCase(trim(ARGUMENTS.returnType))){
			case 'json' :
				
				if( isXML(result.fileContent) ){
					xmlStruct = xmlToStruct(XMLParse(result.fileContent));
					return serializeJSON(xmlStruct);
				}else{
					return trim(result.fileContent);
				}
				
				break;

			default:
			
				return isXML(trim(result.fileContent))? XMLParse(Trim(result.fileContent)) : result.fileContent;
		}
		
	
		
		
		
		
	}
	
	/*
		Search album by Artist, Album Title and/or Track Title. Uses ALBUM_SEARCH command
	*/
	public any function albumSearch(String artist = "",String album="",String track=""){
		
		var body = constructBody(ARGUMENTS.artist,ARGUMENTS.album,ARGUMENTS.track);
		var data = constructRequest(body);
		return send(data);
		
	}
	
	/*
		Fetch Metadata by passing in a Gracenote Identifier (GNID). Uses ALBUM_FETCH command
	*/
	public any function fetchByGNID(String gnid){
		
		
		var body = constructBody("","","",ARGUMENTS.gnid,"ALBUM_FETCH");
		var data = constructRequest(body,"ALBUM_FETCH");
		return send(data);
	}
	
	/*
		Search album by Table of Contents. Uses ALBUM_TOC command
	*/
	public any function albumTOC(String toc=""){
		
		var body = "<TOC><OFFSETS>" & ARGUMENTS.toc & "</OFFSETS></TOC>";
		var data = constructRequest(body,"ALBUM_TOC");
		return send(data);
		
	}
	
	/*
		Constructs main XML for a Gracenote Request.
	*/
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
	
	/*
		Constructs body XML for a Gracenote Request
	*/
	private string function constructBody(String artist="", String album = "", String track = "", String gnid = "", String command=""){
		var body = "";
		
		
		switch(ARGUMENTS.command){
			case 'ALBUM_FETCH' :
			
				body &= "<GN_ID>" & ARGUMENTS.gnid & "</GN_ID>";
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
			body &= "<VALUE>MEDIUM,LARGE,SMALL,XLARGE,THUMBNAIL</VALUE>";
			body &= "</OPTION>";
			
			break;
			
			
		}
		
		
		
		return body;
	}
	
	
	/*
		Checks for Valid Response returned from Gracenote WEB API.
	*/
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
			
		}else{
			throw(message=ARGUMENTS.response);
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
	
	/*
		modified xmlToStruct() function from Ray Camden
		https://gist.github.com/cfjedimaster/4580449
	*/
	private Struct function xmlToStruct(x) {
	    var s = {};
	 
	    if(xmlGetNodeType(x) == "DOCUMENT_NODE") {
	        s[LCase(structKeyList(x))] = xmlToStruct(x[structKeyList(x)]);    
	    }
	 
	    if(structKeyExists(x, "xmlAttributes") && !structIsEmpty(x.xmlAttributes)) { 
	        s['attributes'] = {};
	        for(var item in x.xmlAttributes) {
	            s.attributes[Lcase(item)] = x.xmlAttributes[item];        
	        }
	    }
	    
	    if(structKeyExists(x, "xmlText") && len(trim(x.xmlText))) {
	      s['value'] = x.xmlText;
	    }
	 
	    if(structKeyExists(x, "xmlChildren") && arrayLen(x.xmlChildren)) {
	        for(var i=1; i<=arrayLen(x.xmlChildren); i++) {
	            if(structKeyExists(s, Lcase(x.xmlchildren[i].xmlname))) { 
	                if(!isArray(s[Lcase(x.xmlChildren[i].xmlname)])) {
	                    var temp = s[Lcase(x.xmlchildren[i].xmlname)];
	                    s[Lcase(x.xmlchildren[i].xmlname)] = [temp];
	                }
	                arrayAppend(s[LCase(x.xmlchildren[i].xmlname)], xmlToStruct(x.xmlChildren[i]));                
	             } else {
	             	 //before we parse it, see if simple
	             	 if(structKeyExists(x.xmlChildren[i], "xmlChildren") && arrayLen(x.xmlChildren[i].xmlChildren)) {
	             	 		s[LCase(x.xmlChildren[i].xmlName)] = xmlToStruct(x.xmlChildren[i]);
	             	 } else if(structKeyExists(x.xmlChildren[i],"xmlAttributes") && !structIsEmpty(x.xmlChildren[i].xmlAttributes)) {
	             	 	s[LCase(x.xmlChildren[i].xmlName)] = xmlToStruct(x.xmlChildren[i]);
	                } else {
	                	s[LCase(x.xmlChildren[i].xmlName)] = x.xmlChildren[i].xmlText;
	                }
	             }
	        }
	    }
	    
	    return s;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}