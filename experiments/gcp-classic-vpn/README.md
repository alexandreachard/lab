# Classic VPN Gateway

In this experiment, I provision a legacy policy-based Classic Cloud VPN Gateway on Google Cloud Platform. The setup maps dedicated external static IPs, handles forwarding rules for IPSec traffic protocols, and establishes a secure encrypted tunnel to an on-premises network destination.

## Usage

I use this snippet to instantiate the gateway infrastructure, bind the required forwarding rules, and define static routing paths for legacy network integration: