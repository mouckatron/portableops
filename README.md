# Portableops

Name inspired by OH8STNs Pis :)

Treat your Pis like cattle, not pets. They're for eating, not loving (please don't eat your Raspberry Pis, only real pie).

I don't want to care for my Pis and SD cards (though I carry clones when offgrid) that are connected to my radios, I want to be able to rebuild them from scratch at a moments notice if needed. Herein is the code to do that.

## To run

Change the inventory file to match your local network.

Then from the git cloned directory:

```bash
cd playbooks
ansible-playbook -i ../inventory.yml -e 'callsign=YOURCALL gridsquare=YOURGRID winlink_password=YOURPASSWORD' [portableops705.yml | portableops891.yml]
```

I have a playbook for each of my radios as their configs are slightly different. As I write this, I realise those differences should be in the ansible inventory...
