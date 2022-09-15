<!-- Copyright 2020 AxonIQ B.V.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. -->

## Running Axen Server SE in Kubernetes

To deploy, first run the `deploy-secrets.sh` script:

```
$ ./deploy-secrets
Generating tokens

Generating token for './axonserver.token'
Generating token for './axonserver.admin-token'

Generating files

Generating axonserver.properties

Creating Namespace if needed

namespace/running-se created

Creating/updating Secrets and ConfigMap

secret/axonserver-token created
secret/axonserver-admin-token created
configmap/axonserver-properties created
$
```

Next you can deploy Axon Server using the `deploy-axonserver.sh` script:

```
$ ./deploy-axonserver.sh

Generating certificate for 'axonserver.running-se.svc.cluster.local'
Generating a RSA private key
.................................................................++++
..........++++
writing new private key to 'ssl/axonserver/tls.key'
-----
Signature ok
subject=CN = axonserver.running-se.svc.cluster.local
Getting Private key

Creating/updating certificate secret

secret/axonserver-tls created
Generating files

Generating axonserver.yml

Deploying/updating StatefulSet

statefulset.apps/axonserver created
service/axonserver created
$
```

To test your deployment, you can use the `run_squicktest.sh` script:

```
$ ./run-squicktest.sh
If you don't see a command prompt, try pressing enter.
2022-09-14 14:47:52.124  INFO 1 --- [           main] i.a.t.q.c.QuickAxonServerConfiguration   : Setting up routing policy on a AxonServerCommandBus.
2022-09-14 14:47:52.516  INFO 1 --- [           main] i.a.a.c.impl.AxonServerManagedChannel    : Requesting connection details from axonserver.running-se.svc.cluster.local:8124
2022-09-14 14:47:52.989  INFO 1 --- [           main] i.a.a.c.impl.AxonServerManagedChannel    : Successfully connected to axonserver.running-se.svc.cluster.local:8124
2022-09-14 14:47:53.005  INFO 1 --- [           main] i.a.a.connector.impl.ControlChannelImpl  : Connected instruction stream for context 'default'. Sending client identification
2022-09-14 14:47:53.028  INFO 1 --- [           main] i.a.a.c.command.impl.CommandChannelImpl  : CommandChannel for context 'default' connected, 0 command handlers registered
2022-09-14 14:47:53.032  INFO 1 --- [           main] i.a.a.c.command.impl.CommandChannelImpl  : Registered handler for command 'io.axoniq.testing.quicktester.msg.TestCommand' in context 'default'
2022-09-14 14:47:53.353  INFO 1 --- [mandProcessor-0] i.a.testing.quicktester.TestHandler      : handleCommand(): src = 'QuickTesterApplication.getRunner', msg = 'Hi there! It is Wed Sep 14 14:47:53 GMT 2022.'.
2022-09-14 14:47:53.455  INFO 1 --- [.quicktester]-0] i.a.testing.quicktester.TestHandler      : handleEvent(): msg = 'QuickTesterApplication.getRunner says: Hi there! It is Wed Sep 14 14:47:53 GMT 2022.'.
pod "axonserver-quicktest" deleted
$
```