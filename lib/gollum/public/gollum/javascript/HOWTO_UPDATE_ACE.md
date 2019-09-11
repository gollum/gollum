# How to update the ACE editor component

1. Download a new ACE release from (ajax.org/ace-builds)[https://github.com/ajaxorg/ace-builds/releases].
2. Extract the `src-min-noconflict` folder from the archive and rename it to `ace-x.y.z`, where `x.y.z` matches exactly the release version.
3. Place the version in the javascript directory
4. Update the symlink 'ace' to point to the new version
5. Test if the editor works.
6. Remove the old version
