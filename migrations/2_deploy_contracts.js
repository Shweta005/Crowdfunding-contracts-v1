const {toWei} = web3.utils;
const DAO = artifacts.require('DAO');
const Campaign = artifacts.require('Campaign');


module.exports = async (deployer) => {
    await deployer.deploy(DAO);
    await deployer.deploy(
        Campaign, 
        "Test Campaign", 
        "0x47Fa4FcE51f93cB2344267dC9B6539a448c27cE3",
        20,
        toWei('200'),
        toWei('20'),
        "0x"
        );
    
}