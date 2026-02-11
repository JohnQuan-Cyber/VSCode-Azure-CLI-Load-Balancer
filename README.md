# Deploying Load Balancers and verifying the failover test

**Prerequisite**

Azure Account (Student Account is preferable to learn)
Visual Studio Code
AZ CLI
Understanding in the ARM and Bicep Template Files
Bicep Files (In this repository)


# Steps

**Step 1 - Set the parameters to shorten the commands**

Make sure to sign into the Azure Portal with the commnad az login.
Enter the following variables to set the resource group and the location

* $grp = "RG-LB-Lab"
* $loc = "WestUS"

**Step 2 - Use this commnad to deploy the resource group**

Deploy the resource group with the command below

* az group create --resource-group $grp --location $loc


**Step 3 - Deployment of resources**

Deploy the Virtual Network, Network Security Group, Virtual Machines, Public IP and Load Balancer into the resource group
*Note - You will be prompt to input a password for the Virtual Machines. The work around if you want to by passit while still having a password is adding the "--parameters adminPassword='(create a password)' "

* az deployment group create --resource-group $grp --template-file .\LoadBVNet.bicep
* az deployment group create --resource-group $grp --template-file .\LoadBNSG.bicep
* az deployment group create --resource-group $grp --template-file .\LoadBVM.bicep
* az deployment group create --resource-group $grp --template-file .\LoadBVM2.bicep
* az deployment group create --resource-group $grp --template-file .\LoadBVMJump.bicep
* az deployment group create --resource-group $grp --template-file .\LB-PublicIP.bicep
* az deployment group create --resource-group $grp --template-file .\LoadBalancer.bicep

**Step 4 - Once the Virtual Machines are deployed. Check to see if the following are deployed:**

Verify you have deployed the following

1. RG-LB-Lab
2. LoadBVNet
3. LoadBNSG 
4. LoadBVM/LoadBVM2/LoadBVMJump
5. Load Balancer
6. LB pIP

**Step 5 - Install Apache2**

Now we start installing Apache2 into the load balancer VM1 and VM2. We want to SSH into the Jump VM form the local computer through the command prompt. From there we can SSH into each of the VMs and insert the following commands:

**VM1-LB**

1. ssh azureuser@10.0.1.10  # VM1
2. sudo apt update
3. sudo apt install apache2 -y
4. echo "Hello from VM1" | sudo tee /var/www/html/index.html
5. sudo systemctl enable apache2
6. sudo systemctl start apache2
7. sudo systemctl status apache2  ( it should be running  )
8. exit

**VM2-LB**

1. ssh azureuser@10.0.1.11  # VM2
2. sudo apt update
3. sudo apt install apache2 -y
4. echo "Hello from VM2" | sudo tee /var/www/html/index.html
5. sudo systemctl enable apache2
6. sudo systemctl start apache2
7. sudo systemctl status apache2  ( it should be running  )
8. exit

**Step 6 - Verify Fail-Over**

Obtain the public IP from your load balancer and enter into your local browser with the following:

http://(LB-Public-IP)

Once you press enter you should have the output "Hello form VM1"

To verify the failover, stop the Apache on VM1 and refresh the browser. You should now see "Hellow from VM2"

Now we have set up a load balancer

**Step 7 - Once Everything is done, it's time to delete the deployment**

* az group delete --resource-group $grp --yes --no-wait
