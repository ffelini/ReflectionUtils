package reflection.interfaces
{
	public interface IPublicAPI
	{
		function setApiValue(apiName:String,value:*):Boolean
		function set holder(value:Object):void
		function get holder():Object
		function getApi():Vector.<String>
		function getValue(apiName:String):*
		function getValues(apiName:String):Vector.<Object>
		function getDocumentation(apiName:String):String
			
		function addApi(...apiNamesStringValues):void
		function addApiValues(apiName:String,...apiValues):void
		function addApiDocumentation(apiName:String,documentation:String):void
	}
}