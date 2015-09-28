package utils
{
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import instanceDescription.InstanceDescriptionVO;
	
	public class ClassUtils
	{
		public function ClassUtils()
		{
		}
		public static function getPublicMethods(c:Class):Array
		{
			var description:XML = describeType(c);
			var methodsList:XMLList = description.factory.mehod;
			
			var methods:Array = [];
			
			for each(var method:XML in methodsList)
			{
				methods.push(method.@name);
			}
			return methods;
		}
		public static function getStaticMethods(c:Class):Array
		{
			var description:XML = describeType(c);
			var methodsList:XMLList = description.method;
			var methods:Array = [];
			
			for each(var method:XML in methodsList)
			{
				methods.push(method.@name);
			}
			
			//trace("ClassUtils.getStaticMethods(c)",methods);
			
			return methods;
		}
		public static function getClassByName(className:String):Class
		{
			try{
				return className!="" ? getClassByAlias(className) as Class : null;
			}
			catch(e:Error){}
			return null;
		}
		public static function getClassByInstance(inst:Object,superClass:Boolean=false):Class
		{
			return getClassByName(superClass ? getQualifiedSuperclassName(inst) : getQualifiedClassName(inst));
		}
		public static function registerClass(c:Class):void
		{
			registerClassAlias(getQualifiedClassName(c), c);
		}
		public static function registerClasses(classes:Vector.<Class>):void
		{
			if(!classes) return;
			var numClasses:int = classes.length;
			
			for(var i:int=numClasses-1;i>=0;i--)
			{
				registerClass(classes[i]);
			}
		}
		public static function getInstanceConf(inst:Object,tillParentClass:Class=null):Object
		{
			var tillParentClassName:String = tillParentClass ? getQualifiedClassName(tillParentClass) : "";
			
			var conf:Object = getInstanceConfByClassName(inst);
			
			var xml:XML = describeType(inst);
			var parentClasses:XMLList = xml.extendsClass;
			
			var numClasses:int = parentClasses.length;
			for(var i:int=0;i<numClasses;i++)
			{
				var classXml:XML = parentClasses.getItemAt(i) as XML;
				if(classXml.@type+"" != tillParentClassName && tillParentClassName!="") return conf;
				
				getInstanceConfByClassName(inst,conf,"variable",classXml.@type+"");
			}
			
			return conf;
		}
		public static function getInstanceConfByClassName(inst:Object,conf:Object=null,_type:String="variable",className:String=""):Object
		{
			if(!inst) return null;
			
			if(!conf) conf = new Object();
			
			var variablesInstDescriptor:InstanceDescriptionVO = new InstanceDescriptionVO(inst,"variable","readWrite",className);
			
			var numVariables:int = variablesInstDescriptor.description.length();
			
			for(var i:int = 0;i<numVariables;i++)
			{
				var variable:XML = variablesInstDescriptor.description[i] as XML;
				if(variable.@type+""=="int" || variable.@type+""=="Number" || variable.@type+""=="String" || variable.@type+""=="Boolean")
				{
					if(inst.hasOwnProperty(variable.@name)) conf[variable.@name] = inst[variable.@name];
				}
			}
			
			return conf;
		}
		public static function setInstanceConf(inst:Object,conf:Object):void
		{
			if(!inst || !conf) return;
			
			for(var prop:String in conf)
			{
				if(inst.hasOwnProperty(prop)) inst[prop] = conf[prop];
			}
		}
	}
}