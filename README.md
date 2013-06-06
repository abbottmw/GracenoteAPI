ColdFusion wrapper for Gracenote API (WEB API)
===

Simple wrapper for the <a href="http://www.gracenote.com">Gracenote</a> Music API  using the <a href="https://developer.gracenote.com/web-api">WEB API</a>.

It can be downloaded from Github, or you can <a href="http://gracenoteapi.riaforge.org/index.cfm?event=action.download">download</a> it through RiaForge.

Getting Started
---

You will need a Gracenote Client ID which you can get from <a href="https://developer.gracenote.com">https://developer.gracenote.com/</a>  
Each Application needs to have a User ID.  You can obtain a User ID by registering your client ID with the Gracenote API.  This can be achieved with the **register()** method of this component.  

Usage
---

The WEB API only deals with sending and recieving XML.  You can specify in the Gracenote component if you would like to return JSON instead of XML.  There are two ways to do this.  One is to set the _**returnType**_ argument in the **init()** method to either JSON or XML(default). The other way is to call **setReturnType('json|xml')** before doing a search.  The Gracenote component converts the XML to a JSON string before returning it to the user.

If/When JSON is supported from the WEB API, I'll update this component to use their JSON returned. 



Example
---

```cfm

<!--- pass in clientID, userID (if available) and returnType (XML or JSON) --->
<cfset gracenote = new lib.Gracenote('XXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX','',"xml|json")>

<!---
	Registering Client ID with the API
	You should cache the userID returned from the register() function as you should only call this once.
	If you store the Gracenote.cfc in a persistent scope, register() should ignore multiple calls.
--->

<cfset user = gracenote.register()>


<!---search by Album--->
<cfset search =  gracenote.albumSearch('Moby','Play','Porcelin')>
<cfdump var="#search#">

<hr/>

<!---search by Album Table of Contents--->
<cfset search = gracenote.albumTOC("150 20512 30837 50912 64107 78357 90537 110742 126817 144657 153490 160700 175270 186830 201800 218010 237282 244062 262600 272929")>
<cfdump var="#search#">

<hr/>

<!---Fetch Album by using the Gracenote Identifier (GNID)--->
<cfset search = gracenote.fetchByGNID("97474325-8C600076B380712C6D1C5DC5DC5674F1")>
<cfdump var="#search#">

```
