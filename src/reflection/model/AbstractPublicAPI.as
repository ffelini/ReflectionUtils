package reflection.model
{
	import flash.utils.Dictionary;
	
	import reflection.interfaces.IPublicAPI;

	public class AbstractPublicAPI implements IPublicAPI
	{
		public function AbstractPublicAPI(holder:Object)
		{
			this.holder = holder;
		}
		protected var _holder:Object;
		public function get holder():Object
		{
			return _holder;
		}
		public function set holder(value:Object):void
		{
			_holder = value;
		}
		public function setApiValue(apiName:String,value:*):Boolean
		{
			try{
				holder[apiName] = value;
				return true;
			}catch(e:Error){}
			
			return false;
		}
		protected var api:Vector.<String> = new Vector.<String>();
		protected var docsDict:Dictionary = new Dictionary();
		protected var valuesDict:Dictionary = new Dictionary();
		
		public function getValue(apiName:String):*
		{
			return valuesDict[apiName];
		}
		public function addApiDocumentation(apiName:String,documentation:String):void
		{
			docsDict[apiName] = documentation;
		}
		public function getDocumentation(apiName:String):String
		{
			return docsDict[apiName]+"";
		}
		public function addApi(...apiNamesStringValues):void
		{
			for each(var apiName:String in apiNamesStringValues)
			{
				if(api.indexOf(apiName)<0) api.push(apiName);
			}
		}
		public function getApi():Vector.<String>
		{
			return api;
		}
		public function addApiValues(apiName:String,...apiValues):void
		{
			var values:Vector.<Object> = valuesDict[apiName];
			if(!values)
			{
				values = new Vector.<Object>();
				valuesDict[apiName] = values;
			}
			for each(var apiValue:String in apiValues)
			{
				if(values.indexOf(apiValue)<0) values.push(apiValue);
			}
			addApi(apiName);
		}
		public function addApiValuesList(apiName:String,apiValues:*):void
		{
			var values:Vector.<Object> = valuesDict[apiName];
			if(!values)
			{
				values = new Vector.<Object>();
				valuesDict[apiName] = values;
			}
			for each(var apiValue:String in apiValues)
			{
				if(values.indexOf(apiValue)<0) values.push(apiValue);
			}
			addApi(apiName);
		}
		public function getValues(apiName:String):Vector.<Object>
		{
			return valuesDict[apiName] as Vector.<Object>;
		}
	}
}