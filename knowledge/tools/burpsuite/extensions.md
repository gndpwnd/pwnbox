# Burp Suite Extensions

> Guide to installing, configuring, and developing extensions for Burp Suite.

## Table of Contents

- [Overview](#overview)
- [Installing Extensions](#installing-extensions)
- [Jython and JRuby Setup](#jython-and-jruby-setup)
- [Essential Extensions](#essential-extensions)
- [Extension Categories](#extension-categories)
- [Custom Extension Development](#custom-extension-development)

---

## Overview

Burp Suite's extensibility is one of its most powerful features. Extensions can:
- Add new functionality to existing tools
- Create custom scanning checks
- Automate repetitive tasks
- Integrate with external tools
- Modify requests/responses on the fly

### Extension Types

| Language | File Type | Requirements |
|----------|-----------|--------------|
| Java | .jar | None (native) |
| Python | .py | Jython |
| Ruby | .rb | JRuby |

---

## Installing Extensions

### From BApp Store

```
1. Extender > BApp Store
2. Browse or search for extension
3. Click "Install"
4. Extension appears in "Installed" list
```

### Manual Installation

```
1. Download extension file (.jar, .py, or .rb)
2. Extender > Extensions > Add
3. Select extension type (Java/Python/Ruby)
4. Select extension file
5. Click "Next"
```

### Managing Extensions

```
Extender > Extensions

Actions:
- Enable/Disable: Toggle checkbox
- Remove: Select and click "Remove"
- Reload: Click "Reload" after editing
- Output: View extension logs/errors
```

---

## Jython and JRuby Setup

Required for Python and Ruby extensions respectively.

### Jython Installation (Python)

```bash
# Download standalone JAR
wget https://repo1.maven.org/maven2/org/python/jython-standalone/2.7.3/jython-standalone-2.7.3.jar

# Or from official site
# https://www.jython.org/download
```

Configure in Burp:
```
Extender > Options > Python Environment
Location of Jython standalone JAR file: /path/to/jython-standalone-2.7.3.jar
```

### JRuby Installation (Ruby)

```bash
# Download complete JAR
wget https://repo1.maven.org/maven2/org/jruby/jruby-complete/9.4.3.0/jruby-complete-9.4.3.0.jar

# Or from official site
# https://www.jruby.org/download
```

Configure in Burp:
```
Extender > Options > Ruby Environment
Location of JRuby JAR file: /path/to/jruby-complete-9.4.3.0.jar
```

### Folder for Loading Modules

```
Extender > Options > Python Environment
Folder for loading modules: /path/to/python/modules

# Add pip packages here for import in extensions
```

---

## Essential Extensions

### Must-Have Extensions

#### Logger++

Enhanced logging with filtering and highlighting.

```
Features:
- Advanced filtering (regex, status codes, content type)
- Export to CSV/JSON
- Color-coded entries
- Column customization
- Grep across all traffic

Use cases:
- Track specific parameter across requests
- Export data for offline analysis
- Monitor for specific patterns
```

#### Turbo Intruder

High-speed attack tool using Python scripts.

```python
# Basic usage - Rate limit testing
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                          concurrentConnections=30,
                          requestsPerConnection=100,
                          pipeline=True)

    for word in open('/usr/share/wordlists/common.txt'):
        engine.queue(target.req, word.rstrip())

def handleResponse(req, interesting):
    if req.status == 200:
        table.add(req)
```

```
When to use over Intruder:
- Need >100 requests/second
- Race condition testing
- Custom attack logic
- Complex payload generation
```

#### Autorize

Automatic authorization enforcement detection.

```
Setup:
1. Load extension
2. Browse as low-privilege user
3. Paste high-privilege cookies
4. Autorize replays requests with both sessions

Findings:
- Green: Different responses (proper authz)
- Red: Same responses (broken authz)
- Yellow: Needs manual review
```

#### AuthMatrix

Test authorization across multiple users/roles.

```
Features:
- Define roles matrix (admin, user, guest)
- Define protected resources
- Automatic testing across all combinations
- Visual matrix of results
```

#### Param Miner

Discover hidden parameters and headers.

```
Usage:
1. Right-click request > Extensions > Param Miner > Guess params
2. Or use "Guess everything" for comprehensive scan

Discovers:
- Hidden GET/POST parameters
- JSON parameters
- Custom headers
- Cache key parameters
```

#### Active Scan++

Enhanced scanning checks.

```
Additional checks:
- Host header injection
- Edge Side Includes
- XML input handling
- LDAP injection
- Server-side prototype pollution
```

#### Hackvertor

Tag-based conversion and encoding.

```
Usage in Repeater:
<@base64>admin:password<@/base64>
<@urlencode><@base64>test<@/base64><@/urlencode>

Tags:
- Encoding: base64, url, html
- Hashing: md5, sha1, sha256
- Encryption: aes, xor
- Conversion: dec, hex, bin
```

#### JSON Web Tokens (JWT Editor)

JWT manipulation and attack automation.

```
Features:
- Decode JWT in Proxy/Repeater
- Modify claims
- Attack automation:
  - None algorithm attack
  - Key confusion attacks
  - Brute force secret
```

### SQLMap Integration

Use sqlmap with Burp requests.

```
Option 1: Save request to file
1. Right-click request > Save item
2. sqlmap -r request.txt

Option 2: CO2 extension
- Extender > BApp Store > CO2
- Right-click request > Extensions > CO2 > Send to sqlmap

Option 3: SQLiPy extension
- Configures sqlmap API integration
- Right-click request > SQLiPy
```

---

## Extension Categories

### Reconnaissance

| Extension | Purpose |
|-----------|---------|
| GAP | Discover parameters from JS files |
| JS Link Finder | Extract URLs from JavaScript |
| Wsdler | Parse WSDL files |
| OpenAPI Parser | Import OpenAPI/Swagger specs |
| GraphQL Raider | GraphQL testing support |

### Vulnerability Detection

| Extension | Purpose |
|-----------|---------|
| Backslash Powered Scanner | Advanced injection detection |
| HTTP Request Smuggler | Smuggling vulnerability detection |
| SSRF Detector | Server-side request forgery |
| Taborator | Enhanced Collaborator integration |
| CSRF Scanner | Cross-site request forgery |

### Productivity

| Extension | Purpose |
|-----------|---------|
| Copy as Python Requests | Convert to Python code |
| Request Highlighter | Color-code proxy history |
| Response Clusterer | Group similar responses |
| Burp Bounty | Custom scan profiles |
| Flow | Group and organize requests |

### Reporting

| Extension | Purpose |
|-----------|---------|
| Report to JSON | Export findings as JSON |
| Burp Notes | Take notes on findings |
| Distribute Damage | Track testing coverage |
| Issue Tracker | Link to external issue systems |

---

## Custom Extension Development

### Extension Structure (Python)

```python
from burp import IBurpExtender
from burp import IHttpListener

class BurpExtender(IBurpExtender, IHttpListener):

    def registerExtenderCallbacks(self, callbacks):
        # Save reference to callbacks
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()

        # Set extension name
        callbacks.setExtensionName("My Extension")

        # Register as HTTP listener
        callbacks.registerHttpListener(self)

        print("Extension loaded successfully")

    def processHttpMessage(self, toolFlag, messageIsRequest, messageInfo):
        # Called for every HTTP message
        if messageIsRequest:
            request = messageInfo.getRequest()
            analyzedRequest = self._helpers.analyzeRequest(request)

            # Get headers and body
            headers = analyzedRequest.getHeaders()
            body = request[analyzedRequest.getBodyOffset():]

            # Modify request
            # ...
```

### Extension Structure (Java)

```java
package burp;

public class BurpExtender implements IBurpExtender, IHttpListener {

    private IBurpExtenderCallbacks callbacks;
    private IExtensionHelpers helpers;

    @Override
    public void registerExtenderCallbacks(IBurpExtenderCallbacks callbacks) {
        this.callbacks = callbacks;
        this.helpers = callbacks.getHelpers();

        callbacks.setExtensionName("My Extension");
        callbacks.registerHttpListener(this);

        callbacks.printOutput("Extension loaded");
    }

    @Override
    public void processHttpMessage(int toolFlag, boolean messageIsRequest,
                                   IHttpRequestResponse messageInfo) {
        if (messageIsRequest) {
            byte[] request = messageInfo.getRequest();
            IRequestInfo analyzedRequest = helpers.analyzeRequest(request);

            // Process request
        }
    }
}
```

### Common Interfaces

| Interface | Purpose |
|-----------|---------|
| IBurpExtender | Required for all extensions |
| IHttpListener | Intercept HTTP traffic |
| IProxyListener | Intercept Proxy traffic specifically |
| IScannerCheck | Add custom scanner checks |
| IContextMenuFactory | Add context menu items |
| ITab | Add custom UI tab |
| IMessageEditorTabFactory | Add request/response editor tab |
| ISessionHandlingAction | Custom session handling |

### Adding Context Menu

```python
from burp import IBurpExtender, IContextMenuFactory
from javax.swing import JMenuItem
import java.util.ArrayList as ArrayList

class BurpExtender(IBurpExtender, IContextMenuFactory):

    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        callbacks.setExtensionName("Context Menu Example")
        callbacks.registerContextMenuFactory(self)

    def createMenuItems(self, invocation):
        menu = ArrayList()
        menuItem = JMenuItem("Send to My Tool")
        menuItem.addActionListener(lambda e: self.handleClick(invocation))
        menu.add(menuItem)
        return menu

    def handleClick(self, invocation):
        # Get selected messages
        messages = invocation.getSelectedMessages()
        for message in messages:
            request = message.getRequest()
            # Process request
            print("Processing request...")
```

### Creating Custom Scanner Check

```python
from burp import IBurpExtender, IScannerCheck
from java.util import ArrayList

class BurpExtender(IBurpExtender, IScannerCheck):

    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()
        callbacks.setExtensionName("Custom Scanner")
        callbacks.registerScannerCheck(self)

    def doPassiveScan(self, baseRequestResponse):
        response = baseRequestResponse.getResponse()
        analyzedResponse = self._helpers.analyzeResponse(response)
        body = response[analyzedResponse.getBodyOffset():]

        # Check for sensitive data
        if b"password" in body.lower():
            return [CustomScanIssue(
                baseRequestResponse.getHttpService(),
                self._helpers.analyzeRequest(baseRequestResponse).getUrl(),
                [baseRequestResponse],
                "Password Found in Response",
                "The response contains the word 'password'.",
                "Information"
            )]
        return None

    def doActiveScan(self, baseRequestResponse, insertionPoint):
        # Implement active scanning logic
        return None

    def consolidateDuplicateIssues(self, existingIssue, newIssue):
        if existingIssue.getIssueName() == newIssue.getIssueName():
            return -1  # Discard new issue
        return 0  # Keep both
```

### Debugging Extensions

```
View output and errors:
Extender > Extensions > [Extension] > Output/Errors tabs

Print debugging:
print("Debug message")  # Python
callbacks.printOutput("Debug message");  # Java

Error handling:
try:
    # Risky code
except Exception as e:
    print("Error: " + str(e))
```

### Extension Resources

| Resource | URL |
|----------|-----|
| API Documentation | https://portswigger.net/burp/extender/api |
| Example Extensions | https://github.com/PortSwigger/example-extensions |
| BApp Development | https://portswigger.net/burp/documentation/desktop/extensions/creating |
| Burp Extender Forum | https://forum.portswigger.net/burp-extensions |
