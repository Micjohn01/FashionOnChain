# FashionStoreOnChain

## Overview

The **FashionStoreOnChain** is a decentralized on-chain fashion store implemented as a smart contract on the Ethereum blockchain. It allows the store owner to add products, update them, sell them to customers, process refunds, and manage the contract’s Ether balance securely. The contract enforces several constraints such as maximum price and quantity, ensures accurate payment and refunds, and allows only the owner to manage products.

## Features

**Add Products:** The owner can add new products with a name, price, and quantity.

**Update Products:** The owner can update the price and quantity of existing products.

**Purchase Products:** Users can purchase available products by sending Ether equivalent to the product price.

**Refunds:** Users can request a refund for products they have purchased, and their Ether will be returned.

**Owner-Only Functions:** Only the contract owner can add, update products, and withdraw funds.

**Ether Withdrawal:** The contract owner can withdraw the store's accumulated Ether.

## Usage

**Deployment**

Deploy the contract using Remix or any Ethereum development framework such as Hardhat or Truffle. The contract's constructor automatically assigns the deployer's address as the owner.

**Interaction**

***Adding a Product***

To add a product, the owner must call the addProduct function with the product's name, price, and quantity. The price is specified in Wei (1 Ether = 10^18 Wei).

***Updating a Product***

The owner can update a product's price and quantity using the updateProduct function. Only active products can be updated.

***Purchasing a Product***

Customers can purchase products by calling purchaseProduct and sending the required amount of Ether. If the customer sends more Ether than required, the excess is refunded.

***Requesting a Refund***

Customers can request refunds for products they have purchased using the refundProduct function, provided they have not exceeded their purchase limit.

***Withdrawing Funds***

The owner can withdraw the contract's Ether balance using the withdrawFunds function.

## License

This project is licensed under the MIT License