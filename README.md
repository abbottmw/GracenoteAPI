Coldfusion wrapper for Gracenote API
---

Simple wrapper for the <a href="http://www.gracenote.com">Gracenote</a> Music API  using the <a href="https://developer.gracenote.com/web-api">WEB API</a>

Getting Started
---

You will need a Gracenote Client ID which you can get from <a href="https://developer.gracenote.com">https://developer.gracenote.com/</a>

Each Application needs to have a User ID.  You can obtain a User ID by registering your client ID with the Gracenote API.  

Example Usage
---

```cfm

<!--- pass in the full client id --->
<cfset gracenote = new lib.gracenote('XXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

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
<cfset search = gracenote.fetchByID("97474325-8C600076B380712C6D1C5DC5DC5674F1")>
<cfdump var="#search#">

```





