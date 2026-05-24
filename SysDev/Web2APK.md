
# Convert Website To APK


- CachyOS + Fish shell


## System Packages

```bash
sudo pacman -S nodejs npm
```

## One liner 

- Save to: `~/.config/fish/functions/web2apk.fish`

```bash
function web2apk
    set url $argv[1]
    set domain (string replace -r 'https?://' '' -- $url | string replace -r '/.*' '')
    set build_dir "$HOME/apk-builds/$domain"

    mkdir -p $build_dir; and cd $build_dir

    if not test -f twa-manifest.json
        echo "First run: initializing Bubblewrap for $url"
        echo "Use keystore: ~/cyfare-release.keystore (or let it auto-create)"
        npx @bubblewrap/cli@1.24.1 init --manifest $url/manifest.json
    end

    # Inject storage permissions
    set manifest app/src/main/AndroidManifest.xml
    if test -f $manifest
        if not grep -q "READ_EXTERNAL_STORAGE" $manifest
            sed -i '/<manifest/a \    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />\n    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />' $manifest
        end
        if not grep -q "requestLegacyExternalStorage" $manifest
            sed -i 's/<application/<application android:requestLegacyExternalStorage="true"/' $manifest
        end
    end

    npx @bubblewrap/cli@1.24.1 build

    echo ""
    echo "APK output:"
    ls -la app/build/outputs/apk/release/*.apk
    echo ""
    echo "Upload .well-known/assetlinks.json before distributing:"
    cat app/build/outputs/apk/release/assetlinks.json
end
```

- Run

```bash
source ~/.config/fish/config.fish
web2apk https://cyfare.net
```
