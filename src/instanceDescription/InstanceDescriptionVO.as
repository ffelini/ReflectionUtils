package instanceDescription
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.describeType;
	
	
	public class InstanceDescriptionVO 
	{
		public static const TYPE_ACCESSOR:String = "accessor";
		public static const TYPE_METHOD:String = "method";
		public static const TYPE_VARIABLE:String = "variable";
		
		public static const ACCESS_READ_WRITE:String = "readwrite";
		public static const ACCESS_READ_ONLY:String = "readonly";
		public static const ACCESS_WRITE_ONLY:String = "writeonly";
		
		public var type:String = "accessor";
		public var accessType:String = "readwrite";
		
		public var className:String = "";
		
		public function InstanceDescriptionVO(value:Object,_type:String="accessor",_accessType:String="readwrite",_className:String="")
		{
			type = _type;
			accessType = _accessType
			className = _className;
			
			instance = value;
		}
		public var describeXML:XML;
		public var description:XMLList;
		public var inst:Object;
		public function set instance(value:Object):void
		{
			inst = value;
			describeXML = describeType(inst);
			
			className = className=="" ? describeXML.@name+"" : className;
			
			if(type==TYPE_ACCESSOR) description = describeXML.accessor.(@declaredBy==className && @access==accessType && attribute("uri").length()==0); 
			if(type==TYPE_METHOD) description = describeXML.method.(@declaredBy==className && attribute("uri").length()==0);
			if(type==TYPE_VARIABLE) description = describeXML.variable;//.(@declaredBy==className);		

		}
		private var orderArray:Array = new Array();
		private var excludeArray:Array = new Array();
		public function getDescriptionByFields(fields:Vector.<String>):Array
		{
			orderArray.length = 0;
			excludeArray.length = 0;
			
			var filterFields:Boolean = fields && fields.length>0;
			
			if(!filterFields)
			{
				for each(var item:XML in description)
				{
					if ("@name" in item) 
					{
						if(!filterFields || (filterFields && fields.indexOf(item.@name+"")>=0)) orderArray.push(item);
					}
					else if(!filterFields) excludeArray.push(item);
				}		
			}
			else
			{
				for each(var item:XML in describeXML.accessor)
				{
					if ("@name" in item) 
					{
						if(!filterFields || (filterFields && fields.indexOf(item.@name+"")>=0)) orderArray.push(item);
					}
					else if(!filterFields) excludeArray.push(item);
				}			
				for each(var item:XML in describeXML.method)
				{
					if ("@name" in item) 
					{
						if(!filterFields || (filterFields && fields.indexOf(item.@name+"")>=0)) orderArray.push(item);
					}
					else if(!filterFields) excludeArray.push(item);
				}			
				for each(var item:XML in describeXML.variable)
				{
					if ("@name" in item) 
					{
						if(!filterFields || (filterFields && fields.indexOf(item.@name+"")>=0)) orderArray.push(item);
					}
					else if(!filterFields) excludeArray.push(item);
				}
			}
			
			for(var prop:String in inst){
				orderArray.push(new XML(<item name={prop} type=""/>));
			}
			
			orderArray.sortOn("@name"); 
			
			return orderArray.concat(excludeArray);
		}
		public function toString():String
		{
			var s:String = getQualifiedClassName(inst) + "\n";
			var propertyName:String;
			for each(var property:XML in description)
			{
				propertyName = property.@name;
				if(inst.hasOwnProperty(propertyName)) s += "\n" + propertyName + " = " + inst[propertyName]; 
			}
			return s;
		}
	}
}