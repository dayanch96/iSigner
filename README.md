# Tool for Fast Batch Resigning of iOS Applications

## Steps

> [!NOTE]
> If this is your first time using this tool, уxecute the following commands before you begin:
> ```
> chmod +x /path/to/iSigner/resign.sh
> ```
> ```
> xattr -c /path/to/iSigner/resign.sh
> ```

<ol>
  <li>Open <strong>Keychain Access</strong>, navigate to the <strong>System</strong> tab, and import your certificate</li>
  <li>Move the <strong>*.mobileprovision</strong> profile file to the iSigner folder</li>
  <li>Rename the profile to <strong>embedded.mobileprovision</strong></li>
  <li>Open the <strong>resign.sh</strong> file in a text editor</li>
  <li>Find the line: <strong>certname="iPhone Distribution: John Doe (XX123XXX123)"</strong></li>
  <li>Replace the name and developer ID in the quotes with those specified in your certificate (you can find this in Keychain under the certificate's Common Name), then save and close the file</li>
  <li>Create <strong>source</strong> and <strong>output</strong> folders inside the iSigner folder</li>
  <li>Place the *.ipa files for signing in the <strong>Source</strong> folder</li>
  <li>Double-click the <strong>resign.sh</strong> file to execute the signing process</li>
  <li>Wait for the signing process to finish. The signed .ipa files will appear in the <strong>Output</strong> folder</li>
</ol>

## Credits
<p>This script is based on the work of Artur Kotov, specifically his <a href="https://github.com/zeroqwerty/resignTool">ResignTool</a></p>
<p>The original script was further improved by my friend Dmytro Furman. You can reach him on <a href="https://t.me/mdfurman">Telegram</a></p>
