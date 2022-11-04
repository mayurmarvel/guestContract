const ethers = require('ethers');
require('dotenv').config();

const fs = require('fs');

const url = process.env.RPC_URL

const privateKey = process.env.PRIVATE_KEY


const deploy = async () => {
    const provider = new ethers.providers.JsonRpcProvider(url);

    // Using Wallet to deploy the contract
    const wallet = new ethers.Wallet(privateKey, provider)

    
    // Read the contract artifacts for ABI
    const metadata = JSON.parse(fs.readFileSync('guest_metadata.json').toString())
  
    // Setting gas limit and gas price
    const gasPrice = ethers.utils.formatUnits(await provider.getGasPrice(), 'gwei')
    const options = {gasLimit: 3000000, gasPrice: ethers.utils.parseUnits(gasPrice, 'gwei')}
  
    // Deploying the contract
    const factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, wallet)
    const contract = await factory.deploy(options)
    await contract.deployed()
    console.log(`Contract Address: ${contract.address}`)


}

deploy();
