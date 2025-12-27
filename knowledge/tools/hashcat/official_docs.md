# hashcat - Official Documentation

Source: https://hashcat.net/wiki/

Downloaded: 2025-12-26T20:06:23.822653

---

# [hashcat  
advanced password recovery](/)

* * *

  * [hashcat](/hashcat/ "hashcat")
  * [Forums](/forum/ "Forums")
  * [Wiki](/wiki/ "Wiki")
  * [Tools](/tools/ "Tools")
  * [Events](/events/ "Events")

  

Log In

Sitemap



### Table of Contents

  * Frequently asked questions

  * Source code

  * Hashcat suite

  * Core attack modes

  * Other attacks

  * Most important wiki pages

  * Patches, tips and tricks

  * Howtos, Videos, Papers, Articles, etc. in the wild

    * General guides

    * Hardware

    * Common issues

    * Specific attacks

    * Specific targets

    * Input sources

    * Cloud and scale

    * Contests

    * Other commmon tools

    * Other

## Frequently asked questions

  * [FAQ](/wiki/doku.php?id=frequently_asked_questions "frequently_asked_questions")

**NOTE** : [You cannot use hashcat to recover online
accounts](https://hashcat.net/wiki/doku.php?id=frequently_asked_questions#i_know_an_online_username_how_can_i_use_hashcat_to_crack_it
"https://hashcat.net/wiki/doku.php?id=frequently_asked_questions#i_know_an_online_username_how_can_i_use_hashcat_to_crack_it")
(like Gmail, Instagram, Facebook, Twitter, etc.), because hashcat has no way
to work on online accounts.

## Source code

  * [Github repositories](https://github.com/hashcat "https://github.com/hashcat")

## Hashcat suite

Beyond hashcat itself, there are other useful utilities from the same team,
maintained in separate repositories.

  * [hashcat](/wiki/doku.php?id=hashcat "hashcat") \- World's fastest and most advanced password recovery utility ([source](https://github.com/hashcat/hashcat "https://github.com/hashcat/hashcat"))

  * [hashcat-utils](/wiki/doku.php?id=hashcat_utils "hashcat_utils") \- Small utilities that are useful in advanced password cracking ([source)](https://github.com/hashcat/hashcat-utils "https://github.com/hashcat/hashcat-utils")

  * [maskprocessor](/wiki/doku.php?id=maskprocessor "maskprocessor") \- High-performance word generator with a per-position configurable charset ([source](https://github.com/hashcat/maskprocessor "https://github.com/hashcat/maskprocessor"))

  * [statsprocessor](/wiki/doku.php?id=statsprocessor "statsprocessor") \- Word generator based on per-position Markov chains ([source](https://github.com/hashcat/statsprocessor "https://github.com/hashcat/statsprocessor"))

  * [princeprocessor](/wiki/doku.php?id=princeprocessor "princeprocessor") \- Standalone password candidate generator using the PRINCE algorithm ([source](https://github.com/hashcat/princeprocessor "https://github.com/hashcat/princeprocessor"))

  * [kwprocessor](/wiki/doku.php?id=kwprocessor "kwprocessor") \- Advanced keyboard-walk generator with configureable basechars, keymap and routes ([source)](https://github.com/hashcat/kwprocessor "https://github.com/hashcat/kwprocessor")

Documentation for older hashcat versions like hashcat-legacy, oclHashcat, …
can be found by using the Sitemap button.

## Core attack modes

  * [Dictionary attack](/wiki/doku.php?id=dictionary_attack "dictionary_attack") \- trying all words in a list; also called “straight” mode (attack mode 0, `-a 0`)

  * [Combinator attack](/wiki/doku.php?id=combinator_attack "combinator_attack") \- concatenating words from multiple wordlists (`-a 1`)

  * [Brute-force attack](/wiki/doku.php?id=mask_attack "mask_attack") and [Mask attack](/wiki/doku.php?id=mask_attack "mask_attack") \- trying all characters from given charsets, per position (`-a 3`)

  * [Hybrid attack](/wiki/doku.php?id=hybrid_attack "hybrid_attack") \- combining wordlists+masks (`-a 6`) and masks+wordlists (`-a 7`); can [also be done with rules](/wiki/doku.php?id=toggle_attack_with_rules "toggle_attack_with_rules")

  * [Association attack](/wiki/doku.php?id=association_attack "association_attack") \- use an username, a filename, a hint, or any other pieces of information which could have had an influence in the password generation to attack one specific hash (`-a 9`)

## Other attacks

  * [Rule-based attack](/wiki/doku.php?id=rule_based_attack "rule_based_attack") \- applying rules to words from wordlists; combines with wordlist-based attacks (attack modes 0, 6, and 7)

  * [Toggle-case attack](/wiki/doku.php?id=toggle_case_attack "toggle_case_attack") \- toggling case of characters; now accomplished with rules

## Most important wiki pages

  * [Example hashes](/wiki/doku.php?id=example_hashes "example_hashes")

  * [Hash format guidance](/wiki/doku.php?id=hash_format_guidance "hash_format_guidance") – tools and tips for specific hash types

  * [Brute-Force attack (aka mask attack)](/wiki/doku.php?id=mask_attack "mask_attack")

  * [When I click on hashcat.exe a black window flashes up and then disappears](/wiki/doku.php?id=ubernoobs "ubernoobs")

  * [Timeout Patch](/wiki/doku.php?id=timeout_patch "timeout_patch")

  * [HCCAPX format description](/wiki/doku.php?id=hccapx "hccapx")

  * [Resuming cracking jobs and .restore file format description](/wiki/doku.php?id=restore "restore")

  * [Cracking WPA/WPA2 with hashcat](/wiki/doku.php?id=cracking_wpawpa2 "cracking_wpawpa2")

  * [Using maskprocessor to generate rules](/wiki/doku.php?id=rules_with_maskprocessor "rules_with_maskprocessor")

  * [Using rules to emulate hybrid attack](/wiki/doku.php?id=hybrid_atttack_with_rules "hybrid_atttack_with_rules")

  * [Using rules to emulate toggle attack](/wiki/doku.php?id=toggle_attack_with_rules "toggle_attack_with_rules")

  * [Using machine-readable output](/wiki/doku.php?id=machine_readable "machine_readable")

  * [Distributing work](/wiki/doku.php?id=distributing-work "distributing-work")

  * [Hash type categories](/wiki/doku.php?id=hash-type-categories "hash-type-categories")

  * [Ubuntu Server + AMD Catalyst + hashcat HOWTO](/wiki/doku.php?id=linux_server_howto "linux_server_howto") (not up-to-date)

  * [HOWTO: Upgrading AMD Drivers on Windows](/wiki/doku.php?id=upgrading_amd_drivers_how_to "upgrading_amd_drivers_how_to") (not up-to-date)

  * [hashcat and the drivers: Catalyst and ForceWare](/wiki/doku.php?id=oclhashcat_catalyst_forceware "oclhashcat_catalyst_forceware") (not up-to-date)

  * ~~[Table-Lookup Attack beginner guide](/wiki/doku.php?id=table_lookup_beginner_guide "table_lookup_beginner_guide")~~ \- only available in [hashcat-legacy](/wiki/doku.php?id=hashcat-legacy "hashcat-legacy")

  * ~~[Distributing workload in oclHashcat-lite](/wiki/doku.php?id=distributing_workload_in_oclhashcat_lite "distributing_workload_in_oclhashcat_lite")~~ \- now accomplished with `-s/--skip` and `-l/--limit`

  * ~~[VCL Cluster HOWTO](/wiki/doku.php?id=vcl_cluster_howto "vcl_cluster_howto")~~

  * ~~[Distributing workload in oclHashcat](/wiki/doku.php?id=distributing_workload_in_oclhashcat "distributing_workload_in_oclhashcat")~~

  * ~~[Using maskprocessor to emulate brute-force attack](/wiki/doku.php?id=brute_force_in_oclhashcat_plus "brute_force_in_oclhashcat_plus")~~ \- now implemented directly in [hashcat](/wiki/doku.php?id=hashcat "hashcat")

  * ~~[Using maskprocessor to emulate mask attack in hashcat](/wiki/doku.php?id=mask_attack_in_hashcat "mask_attack_in_hashcat")~~ \- now implemented directly in [hashcat](/wiki/doku.php?id=hashcat "hashcat")

* _Strike-through = Outdated article_

## Patches, tips and tricks

  * [Calculating total combinations for masks](/wiki/doku.php?id=combination_count_formula "combination_count_formula")

  * [SSH into running terminal](/wiki/doku.php?id=ssh_running_process "ssh_running_process") \- using `screen`

  * [I use hashcat on Windows and want to access it through ssh](/wiki/doku.php?id=hashcat_on_windows_ssh "hashcat_on_windows_ssh")

  * ~~[Changing fan speed of ATI under linux](/wiki/doku.php?id=changing_fan_speed_of_ati_under_linux "changing_fan_speed_of_ati_under_linux")~~

  * ~~[WPA Clean and Convert Script](/wiki/doku.php?id=wpa_clean_and_convert_script "wpa_clean_and_convert_script")~~

* _Strike-through = Outdated article_

## Howtos, Videos, Papers, Articles, etc. in the wild

If your hashcat article is not listed, tell us. We would love to link it here.

### General guides

  * [A cheat-sheet for password crackers](https://www.unix-ninja.com/p/A_cheat-sheet_for_password_crackers "https://www.unix-ninja.com/p/A_cheat-sheet_for_password_crackers")

  * [A guide to password cracking with Hashcat](https://www.unix-ninja.com/p/A_guide_to_password_cracking_with_Hashcat "https://www.unix-ninja.com/p/A_guide_to_password_cracking_with_Hashcat")

  * [Introduction to Hashcat](https://www.youtube.com/watch?v=EfqJCKWtGiU "https://www.youtube.com/watch?v=EfqJCKWtGiU")

  * [Passwords: A step-by-step analysis of breaking them](https://www.pentestpartners.com/security-blog/passwords-a-step-by-step-analysis-of-breaking-them/ "https://www.pentestpartners.com/security-blog/passwords-a-step-by-step-analysis-of-breaking-them/")

  * [A Practical Guide to Cracking Password Hashes](https://labs.withsecure.com/publications/a-practical-guide-to-cracking-password-hashes "https://labs.withsecure.com/publications/a-practical-guide-to-cracking-password-hashes")

  * [Passwordscon: Advanced Password Cracking: Hashcat Techniques for the Last 20%](https://www.youtube.com/watch?v=9l6COVMer8M "https://www.youtube.com/watch?v=9l6COVMer8M")

  * [Cracking Story – How I Cracked Over 122 Million SHA1 and MD5 Hashed Passwords](https://blog.thireus.com/cracking-story-how-i-cracked-over-122-million-sha1-and-md5-hashed-passwords/ "https://blog.thireus.com/cracking-story-how-i-cracked-over-122-million-sha1-and-md5-hashed-passwords/")

  * [HASHCAT: GPU PASSWORD CRACKING FOR MAXIMUM WIN](https://abigisp.com/talks/hashcat/ "https://abigisp.com/talks/hashcat/")

  * [In.security cracking introduction videos](https://www.youtube.com/@in.security8450 "https://www.youtube.com/@in.security8450") “(Password Cracking 101+1)”

  * [Intro to Hash Cracking](https://github.com/cyclone-github/writeups/blob/main/Intro%20to%20Hash%20Cracking%20-%20Cyclone.pdf "https://github.com/cyclone-github/writeups/blob/main/Intro%20to%20Hash%20Cracking%20-%20Cyclone.pdf") (cyclone)

  * [Awesome Password Cracking](https://github.com/n0kovo/awesome-password-cracking "https://github.com/n0kovo/awesome-password-cracking") (n0kovo)

### Hardware

  * [Building a Password Cracking Rig for Hashcat](https://www.unix-ninja.com/p/Building_a_Cracking_Rig_for_Hashcat "https://www.unix-ninja.com/p/Building_a_Cracking_Rig_for_Hashcat")

  * [Building a Password Cracking Rig for Hashcat - Part II](https://www.unix-ninja.com/p/Building_a_Password_Cracking_Rig_for_Hashcat_-_Part_II "https://www.unix-ninja.com/p/Building_a_Password_Cracking_Rig_for_Hashcat_-_Part_II")

  * [Password Village hardware guide](https://passwordvillage.org/hardware.html "https://passwordvillage.org/hardware.html")

### Common issues

  * [Hashcat Line Length Exceptions](https://www.unix-ninja.com/p/Hashcat_Line_Length_Exceptions "https://www.unix-ninja.com/p/Hashcat_Line_Length_Exceptions")

  * Also see our [FAQ](https://hashcat.net/wiki/doku.php?id=frequently_asked_questions "https://hashcat.net/wiki/doku.php?id=frequently_asked_questions")

### Specific attacks

  * [Custom charsets and rules with John The Ripper and oclhashcat](https://www.pentestpartners.com/security-blog/custom-charsets-and-rules-with-john-the-ripper-and-oclhashcat/ "https://www.pentestpartners.com/security-blog/custom-charsets-and-rules-with-john-the-ripper-and-oclhashcat/")

  * [Efficient Password Cracking Where LM Hashes Exist for Some Users](https://www.pentestpartners.com/security-blog/efficient-password-cracking-where-lm-hashes-exist-for-some-users/ "https://www.pentestpartners.com/security-blog/efficient-password-cracking-where-lm-hashes-exist-for-some-users/")

  * [Hashcat Per Position Markov Chains](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/hashcat-per-position-markov-chains/ "https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/hashcat-per-position-markov-chains/")

  * [Passwordscon: I have the hashcat, I make the rules](https://hashcat.net/events/p14-vegas/I%20have%20the%20%23cat%20i%20make%20the%20rules_YC.pdf "https://hashcat.net/events/p14-vegas/I%20have%20the%20%23cat%20i%20make%20the%20rules_YC.pdf")

  * [Rule-Fu: The art of word mangling](https://web.archive.org/web/20131111231827/http://ob-security.info/?p=31 "https://web.archive.org/web/20131111231827/http://ob-security.info/?p=31")

  * [Passwords^12: Exploiting a SHA-1 weakness in password cracking](https://www.youtube.com/watch?v=7YebpMoK9VQ "https://www.youtube.com/watch?v=7YebpMoK9VQ")

  * [Cracking an MD5 of an IP address](https://www.phillips321.co.uk/2012/04/04/cracking-an-md5-of-an-ip-address/ "https://www.phillips321.co.uk/2012/04/04/cracking-an-md5-of-an-ip-address/")

  * [Tool Deep Dive: PRINCE](https://reusablesec.blogspot.com/2014/12/tool-deep-dive-prince.html "https://reusablesec.blogspot.com/2014/12/tool-deep-dive-prince.html")

  * [Video introduction to Hashcat v3 and Debug-Rules example](https://www.youtube.com/watch?v=0C5jftc4nqs "https://www.youtube.com/watch?v=0C5jftc4nqs")

  * [Exploiting masks in Hashcat for fun and profit](https://www.unix-ninja.com/p/Exploiting_masks_in_Hashcat_for_fun_and_profit "https://www.unix-ninja.com/p/Exploiting_masks_in_Hashcat_for_fun_and_profit")

  * [Statistics Will Crack Your Password](https://www.praetorian.com/blog/statistics-will-crack-your-password-mask-structure/ "https://www.praetorian.com/blog/statistics-will-crack-your-password-mask-structure/")

  * [n0kovo's hashcat rules collection](https://github.com/n0kovo/hashcat-rules-collection "https://github.com/n0kovo/hashcat-rules-collection")

  * [Password shucking attack - DEF CON talk](https://www.youtube.com/watch?v=OQD3qDYMyYQ "https://www.youtube.com/watch?v=OQD3qDYMyYQ") (Chick3nman)

### Specific targets

  * [ Agilebits 1Password support and Design Flaw?](https://hashcat.net/forum/thread-2238.html "https://hashcat.net/forum/thread-2238.html")

  * [Cracking Android passwords, a how-to](https://www.pentestpartners.com/security-blog/cracking-android-passwords-a-how-to/ "https://www.pentestpartners.com/security-blog/cracking-android-passwords-a-how-to/")

  * [Android Pin/Password Cracking](https://linuxsleuthing.blogspot.com/2012/10/android-pinpassword-cracking-halloween.html "https://linuxsleuthing.blogspot.com/2012/10/android-pinpassword-cracking-halloween.html")

  * [CheckPoint Security Gateway (firewall) and Security Management password hashes](https://hashcat.net/forum/thread-4436.html "https://hashcat.net/forum/thread-4436.html")

  * [Cracking IKE Mission:Improbable (Part 1)](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/cracking-ike-missionimprobable-part-1/ "https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/cracking-ike-missionimprobable-part-1/")

  * [Cracking IKE Mission:Improbable (Part 2)](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/cracking-ike-missionimprobable-part-2/ "https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/cracking-ike-missionimprobable-part-2/")

  * [known_hosts hash cracking with hashcat](https://github.com/chris408/known_hosts-hashcat "https://github.com/chris408/known_hosts-hashcat")

  * [Convert metasploit cachedump files to Hashcat format for cracking](https://www.commandlinefu.com/commands/view/11574/convert-metasploit-cachedump-files-to-hashcat-format-for-cracking "https://www.commandlinefu.com/commands/view/11574/convert-metasploit-cachedump-files-to-hashcat-format-for-cracking")

  * [Colliding password protected MS office 97-2003 documents](https://hashcat.net/forum/thread-3665.html "https://hashcat.net/forum/thread-3665.html")

  * [Cracking Netgear default WPA passwords with oclHashcat](https://hashcat.net/forum/thread-4463.html "https://hashcat.net/forum/thread-4463.html")

  * [How to Extract OS X Mavericks Password Hash for Cracking With Hashcat](https://web.archive.org/web/20140703020831/http://www.michaelfairley.co/blog/2014/05/18/how-to-extract-os-x-mavericks-password-hash-for-cracking-with-hashcat/ "https://web.archive.org/web/20140703020831/http://www.michaelfairley.co/blog/2014/05/18/how-to-extract-os-x-mavericks-password-hash-for-cracking-with-hashcat/")

  * [Colliding password protected PDF documents](https://hashcat.net/forum/thread-3818.html "https://hashcat.net/forum/thread-3818.html")

  * [Explaining the PostgreSQL pass-the-hash vulnerability](https://hashcat.net/forum/thread-4148.html "https://hashcat.net/forum/thread-4148.html")

  * [Cracking eight different TrueCrypt ciphers for the price of three](https://hashcat.net/forum/thread-4812.html "https://hashcat.net/forum/thread-4812.html")

  * [Cracking TrueCrypt: container, non-system, system, hidden](https://web.archive.org/web/20161026005447/0x31.de/cracking-truecrypt-container-non-system-system/ "https://web.archive.org/web/20161026005447/0x31.de/cracking-truecrypt-container-non-system-system/") (archived on archive.org, current version contains adware)

  * [How to crack WPA2-Enterprise EAP-MD5 with hashcat](http://www.securitybydefault.com/2014/01/wpa2-enterprise-cracking-de-eap-md5.html "http://www.securitybydefault.com/2014/01/wpa2-enterprise-cracking-de-eap-md5.html")

### Input sources

  * [weakpass cyclone+hashesorg+hashkiller combined wordlist](https://weakpass.com/wordlist/1927 "https://weakpass.com/wordlist/1927")

  * [Facebook full directory of first and lastnames, 8GB, sorted with counts, latin and non-latin](https://hashcat.net/forum/thread-4114.html "https://hashcat.net/forum/thread-4114.html")

  * [n0kovo subdomains](https://github.com/n0kovo/n0kovo_subdomains "https://github.com/n0kovo/n0kovo_subdomains") \- wordlist from Internet-wide list of SSL certs

  * [Leipzig word corpora](https://wortschatz.uni-leipzig.de/en/download/ "https://wortschatz.uni-leipzig.de/en/download/")

  * [Google ngrams](https://storage.googleapis.com/books/ngrams/books/datasetsv3.html "https://storage.googleapis.com/books/ngrams/books/datasetsv3.html")

### Cloud and scale

  * [Hashtopolis](https://github.com/hashtopolis "https://github.com/hashtopolis") \- multi-rig clustering server software

  * [Confessions of a crypto cluster operator](https://www.youtube.com/watch?v=1MiY44KS-y4 "https://www.youtube.com/watch?v=1MiY44KS-y4") (EvilMog)

  * [GPU Based Password Cracking with Amazon EC2 and oclHashcat](http://www.rockfishsec.com/2015/05/gpu-password-cracking-with-amazon-ec2.html "http://www.rockfishsec.com/2015/05/gpu-password-cracking-with-amazon-ec2.html")

  * [dizcsza/docker-hashcat](https://hub.docker.com/r/dizcza/docker-hashcat "https://hub.docker.com/r/dizcza/docker-hashcat") \- hashcat-specific Docker image

### Contests

  * [Team Hashcat - team list, event writeups, and tools](https://github.com/hashcat/team-hashcat "https://github.com/hashcat/team-hashcat")

  * [PHDays 2014, "Hashrunner challenge" Writeup - Team Hashcat](https://hashcat.net/forum/thread-3397.html "https://hashcat.net/forum/thread-3397.html")

  * [PHDays 2015, "Hashrunner challenge" Writeup - Team Hashcat](https://hashcat.net/forum/thread-4370.html "https://hashcat.net/forum/thread-4370.html")

  * [DEFCON 2010, "Crack Me If You Can" Writeup - Team Hashcat](https://contest-2010.korelogic.com/team_hashcat.html "https://contest-2010.korelogic.com/team_hashcat.html")

  * [DEFCON 2011, "Crack Me If You Can" Writeup - Team Hashcat](https://contest-2011.korelogic.com/team_hashcat.html "https://contest-2011.korelogic.com/team_hashcat.html")

  * [DEFCON 2014, "Crack Me If You Can" Writeup - Team Hashcat](https://contest-2014.korelogic.com/team_hashcat.html "https://contest-2014.korelogic.com/team_hashcat.html")

  * [DEFCON 2015, "Crack Me If You Can" Writeup - Team Hashcat](https://hashcat.net/forum/thread-4595.html "https://hashcat.net/forum/thread-4595.html")

### Other commmon tools

  * [hashcat-utils](/wiki/doku.php?id=hashcat_utils "hashcat_utils") \- many small utilities useful in advanced password cracking

  * hashcat's [test.pl](https://github.com/hashcat/hashcat/blob/master/tools/test.pl "https://github.com/hashcat/hashcat/blob/master/tools/test.pl") \- generate hashes from wordlists

  * [hashgen](https://github.com/cyclone-github/hashgen "https://github.com/cyclone-github/hashgen") \- quickly generate some common hash types from wordlists

  * [hcxdumptool](https://github.com/ZerBea/hcxdumptool "https://github.com/ZerBea/hcxdumptool") and [hcxtools](https://github.com/ZerBea/hcxtools "https://github.com/ZerBea/hcxtools") \- the modern way to capture and process Wi-Fi hashes

  * [John the Ripper](https://www.openwall.com/john/ "https://www.openwall.com/john/") \- supports some hash types hashcat does not

  * [MDXfind](https://www.techsolvency.com/pub/bin/mdxfind/ "https://www.techsolvency.com/pub/bin/mdxfind/") \- supports multiple iterations of many hash types (CPU only)

  * [PACK](https://github.com/Hydraze/pack "https://github.com/Hydraze/pack") \- tools to analyze founds, generate masks that match policy, etc.

  * [pack2](https://github.com/hops/pack2 "https://github.com/hops/pack2") \- split strings on character boundaries, filter by mask, generate stats, unhex HEX

  * [rling](https://github.com/Cynosureprime/rling "https://github.com/Cynosureprime/rling") \- fast dedupe and sorting of large lists

  * [RuleProcessorY](https://github.com/TheWorkingDeveloper/ruleprocessorY "https://github.com/TheWorkingDeveloper/ruleprocessorY") \- apply rules to wordlists - supports multibyte; slower than direct GPU rules

  * [rurasort](https://github.com/bitcrackcyber/rurasort "https://github.com/bitcrackcyber/rurasort") \- wordlist processing

  * [slider](https://github.com/Cynosureprime/slider "https://github.com/Cynosureprime/slider") \- get sliding window of substrings from a wordlist

### Other

  * [How not to salt a hash](https://hashcat.net/forum/thread-4429.html "https://hashcat.net/forum/thread-4429.html")

  * [Cracking Suite Algorithm Rosetta Stone](https://docs.google.com/spreadsheets/d/1SBv-oRbXb8OapSD1BSPClPXIfiWOL2oH_zTls4sz1rk/edit#gid=0 "https://docs.google.com/spreadsheets/d/1SBv-oRbXb8OapSD1BSPClPXIfiWOL2oH_zTls4sz1rk/edit#gid=0") \- which software support which algorithms - WIP

  * [Troy Hunt: Our password hashing has no clothes](https://www.troyhunt.com/our-password-hashing-has-no-clothes/ "https://www.troyhunt.com/our-password-hashing-has-no-clothes/")

  * [Passwordscon: Optimizing the Computation of Hash Algorithms as an Attacker](https://www.youtube.com/watch?v=SEiL9fqcEwk "https://www.youtube.com/watch?v=SEiL9fqcEwk")

  * [Avoid "dehashing", "reversing", "decrypting", etc. when talking about password hashes](https://www.techsolvency.com/passwords/dehashing-reversing-decrypting/ "https://www.techsolvency.com/passwords/dehashing-reversing-decrypting/")

Back to top

Except where otherwise noted, content on this wiki is licensed under the
following license: [Public
Domain](http://creativecommons.org/licenses/publicdomain/)

