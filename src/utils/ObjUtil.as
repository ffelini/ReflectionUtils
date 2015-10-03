package utils
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display3D.textures.Texture;
import flash.events.Event;
import flash.net.getClassByAlias;
import flash.sampler.getSize;
import flash.system.System;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;
import flash.utils.setTimeout;

public class ObjUtil
	{
		public function ObjUtil()
		{
		}
		public static function getObjSize(obj:Object):Number
		{
			var num:Number = Number( getSize(obj) / 1024 / 1024 );
			obj = null;
			return num;
		}
		public static function dispose(obj:Object,forceGC:Boolean=false,debug:Boolean=false):void
		{
			if(debug) trace("ObjUtil.dispose before",obj,getObjSize(obj));
			
			if(obj is Texture) (obj as Texture).dispose();
			if(obj.hasOwnProperty("dispose") && obj["dispose"] is Function) obj["dispose"]();
			if(obj is BitmapData) (obj as BitmapData).dispose();
			if(obj is Bitmap && (obj as Bitmap).bitmapData) 
			{
				(obj as Bitmap).bitmapData.dispose();
				(obj as Bitmap).bitmapData = null;
			}
			if(obj is Shape) (obj as Shape).graphics.clear();
			
			if(debug) setTimeout(function():void{trace("ObjUtil.dispose after",obj,getObjSize(obj))},5000);
			else obj = null;
			
			if(forceGC) startGCCycle();
		}
		private static var gcCount:int;
		private static function startGCCycle():void
		{
			System.pauseForGCIfCollectionImminent();
			/*try {
				new LocalConnection().connect('foo');
				new LocalConnection().connect('foo');
			} catch (e:*) {}*/
			gcCount = 0;
			//if(stage) stage.addEventListener(Event.ENTER_FRAME, doGC);
		}
		private static function doGC(evt:Event):void
		{
			System.gc();
			if(++gcCount > 1)
			{
				evt.target.removeEventListener(Event.ENTER_FRAME, doGC);
				setTimeout(lastGC, 40);
			}
			trace("ObjUtil.doGC(evt)");
		}
		private static function lastGC():void
		{
			System.gc();
		}
		public static function toString(obj:Object):String
		{
			if(!obj) return "null";
			
			var s:String = obj + "\n";
			for(var p:String in obj)
			{
				if(obj[p] && obj[p].constructor.toString().indexOf("Object") != -1) s += toString(obj[p]);
				else s += "\n" + p +" - " + obj[p];
			}
			return s;
		}
		public static function cloneInstance(inst:Object):Object
		{
			try{
				var c:Class = getClass(inst);
				return new c();
			}
			catch(e:Error){}
			
			return null;
		}
		public static function getClass(inst:Object):Class
		{
			var cl:Class = Object(inst).constructor;
			if(cl) return cl;
			
			var className:String = getQualifiedClassName(inst);
			cl = getDefinitionByName(className) as Class;
			if(cl) return cl;

			try{
				return getClassByAlias(getClassName(inst));
			}catch(e:Error){}
			return null;
		}
		public static function getClassName(inst:Object):String
		{
			var splited:Array = getQualifiedClassName(inst).split(":");
			return splited.length>1 ? splited[1]+"" : splited[0]+"";
		}
		public static function cloneFields(from:Object,to:Object,...properties):Object
		{
			return cloneFieldsList(from,to,properties);
		}
		public static function cloneFieldsList(from:Object,to:Object,properties:*):Object
		{
			if(!from || !to) return to;
			
			if(properties && properties.length>0)
			{
				for each(var p:String in properties)
				{
					try{
						to[p] = from[p];
					}
					catch(e:Error){
						try{
							if(to.hasOwnProperty(p))
							{	
								if(!(to is XML) && (from is XML)) 
								{
									var valueStr:String = from[p].toString();
									if(valueStr=="false") to[p] = false;
									else if(valueStr=="true") to[p] = true;
									else
									{	
										try{ to[p] = valueStr;}
										catch(e:Error){
											try{ to[p] = uint(valueStr);}
											catch(e:Error){
												
												try{ to[p] = parseFloat(valueStr);}
												catch(e:Error){
													
												}
											}
										}
									}
								}
								else to[p] = from[p];
							}
						}catch(e:Error){}
					}
				}
			}
			else
			{
				for(var prop:String in from)
				{
					try{
						if(to.hasOwnProperty(prop)) to[prop] = from[prop];
					}catch(e:Error){}
				}
			}
			return to;
		}
		public static function filterFuncParams(func:Function,params:Array):Array
		{
			if(func==null) return null;
			
			var params:Array = params.splice(0,func.length);
			if(params.length<func.length) params[func.length-1] = null;
			return params;
		}
		/**
		 * Is registering in to and class instance and instance as a public property
		 * @param to class object that sould have the isntance.name property to register
		 * @param instance
		 * @return 
		 * 
		 */		
		public static function registerInstance(to:Object,instance:Object):Boolean
		{
			try{
				if(to.hasOwnProperty(instance.name)) to[instance.name] = instance;
				return true;
			}catch(e:Error){};
			return false;
		}
		public static function isExtensionOf(instance:*,extensClass:Class):Boolean
		{
			return getQualifiedSuperclassName(instance)==getQualifiedClassName(extensClass);
		}
	}
}