package mobile.backend;

#if android
import extension.androidtools.os.Environment;
import extension.androidtools.Settings;
import extension.androidtools.Permissions;
import extension.androidtools.os.Build.VERSION;
import extension.androidtools.os.Build.VERSION_CODES;
#end
import lime.app.Application;

using StringTools;

/** 
* @Authors StarNova (Cream.BR)
* @version: 0.1.0 (Under Development)
**/

class StorageSystem {
  
    public static inline function getStorageDirectory():String
	  	return #if android haxe.io.Path.addTrailingSlash(Environment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file')) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;
	
	public static function getDirectory():String
	{
		#if android
		return Environment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file') + '/';
		#elseif ios
		return lime.system.System.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	/**
	 * Request permission to access the files
	 */
	public static function getPermissions():Void {
		if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU) {
			Permissions.requestPermissions([
				'READ_MEDIA_IMAGES',
				'READ_MEDIA_VIDEO',
				'READ_MEDIA_AUDIO',
				'READ_MEDIA_VISUAL_USER_SELECTED'
			]);
		}
		else {
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
	    }

		/**
         * For Android 11
         */
		if (!Environment.isExternalStorageManager()) {
            Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
	}
}