package mobile.backend;

import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
#if android
import extension.androidtools.os.Environment;
import extension.androidtools.Settings;
import extension.androidtools.Permissions;
import extension.androidtools.os.Build.VERSION;
import extension.androidtools.os.Build.VERSION_CODES;
import extension.androidtools.Tools;
#end
import lime.app.Application;
import haxe.io.Path;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
using StringTools;

/** 
 * @Authors StarNova (Cream.BR)
 * @version: 0.1.2
**/
class StorageSystem
{
	public static inline function getStorageDirectory():String
		return #if android Path.addTrailingSlash(Environment.getExternalStorageDirectory() + '/.' +
			Application.current.meta.get('file')) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

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
	 * Request permission to access the files, only if they are not already granted.
	 */
	public static function getPermissions():Void
	{
		#if android
		try
		{
			var needsPermissions:Bool = false;
			var sdk:Int = VERSION.SDK_INT;

			var granted:Array<String> = Permissions.getGrantedPermissions();

			if (sdk >= VERSION_CODES.TIRAMISU)
			{
				// Android 13+
				if (!granted.contains('READ_MEDIA_IMAGES') || !granted.contains('READ_MEDIA_AUDIO'))
				{
					needsPermissions = true;
					Permissions.requestPermissions([
						'READ_MEDIA_IMAGES',
						'READ_MEDIA_VIDEO',
						'READ_MEDIA_AUDIO',
						'READ_MEDIA_VISUAL_USER_SELECTED'
					]);
				}
			}
			else
			{
				// Android 12 and lower
				if (!granted.contains('WRITE_EXTERNAL_STORAGE'))
				{
					needsPermissions = true;
					Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
				}
			}

			if (sdk >= VERSION_CODES.R)
			{
				if (!Environment.isExternalStorageManager())
				{
					needsPermissions = true;
					Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
				}
			}

			if (needsPermissions)
			{
				Tools.showAlertDialog("Requires permissions", "Please allow the necessary permissions to play.\nPress OK & let's see what happens",
					{name: "OK", func: null}, null);
			}
			else
			{
				trace("All permissions already granted.");
			}
		}
		catch (e:Dynamic)
		{
			trace('Erro ao Solicitar Permissoes: $e');
		}
		#else
		trace("Permissions request not required or not implemented for this platform.");
		#end
	}
	public static function copyAssetsFromApk(sources:Array<String>, targetPath:String = null):Void
{
    #if android
    try
    {
        var baseDest = (targetPath == null) ? getDirectory() : targetPath;
        if (baseDest == null) {
            trace("ERRO: Diretório de destino é nulo!");
            return;
        }
        var assetList:Array<String> = lime.utils.Assets.list();
        var filesCopied:Int = 0;

        trace('INFO: Verificando ${assetList.length} assets no pacote...');

        for (source in sources)
        {
            var filter = haxe.io.Path.normalize(source);
            
            trace('--- Sincronizando: $filter ---');

            for (assetPath in assetList)
            {
                if (StringTools.startsWith(assetPath, filter))
                {
                    var fullTargetPath = haxe.io.Path.join([baseDest, assetPath]);
                    var directory = haxe.io.Path.directory(fullTargetPath);

                    if (assetPath == filter || assetPath == filter + "/") continue;
                    
                    if (StringTools.endsWith(assetPath, ".json") && assetPath.contains("manifest")) continue;

                    if (!FileSystem.exists(directory))
                        FileSystem.createDirectory(directory);

                    if (!FileSystem.exists(fullTargetPath))
                    {
                        try
                        {
                            var data = lime.utils.Assets.getBytes(assetPath);

                            if (data != null)
                            {
                                File.saveBytes(fullTargetPath, data);
                                filesCopied++;
                                trace('COPIADO: $assetPath');
                            }
                        }
                        catch (e:Dynamic)
                        {
                            trace('FALHA ao ler bytes de $assetPath: $e');
                        }
                    }
                }
            }
        }
        trace('Sincronização concluída. Arquivos novos: $filesCopied');
    }
    catch (e:Dynamic)
    {
        trace('ERRO CRÍTICO: $e');
    }
    #end
}
}