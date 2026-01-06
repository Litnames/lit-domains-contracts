# 🔥 Lit Domains Contracts

> **Official Name Service for . lit domains** — Your decentralized identity on the blockchain

A comprehensive smart contract suite for managing domain names on the Lit Protocol ecosystem. Built with Solidity, powered by Foundry, and designed for the next generation of decentralized web identities.

---

## ✨ What is Lit Domains?

Lit Domains is a blockchain-based naming service that allows users to register, own, and manage `.lit` domain names. Think of it as your Web3 passport — a human-readable address that replaces long cryptographic wallet addresses with memorable names like `yourname.lit`.

### Core Features

- **🏷️ Domain Registration** — Register and own your `.lit` domain with full control
- **💰 Dynamic Pricing** — Smart pricing based on domain length with time-based discounts
- **⚡ Auction System** — Fair launch mechanism for premium domain distribution
- **🔄 Resolvers** — Map domains to addresses, content hashes, and metadata
- **🛡️ Secure Registry** — Battle-tested architecture with ownership management
- **📊 Pyth Oracle Integration** — Real-time ETH/USD pricing for fair domain costs

---

## 🏗️ Architecture

The system is built on four main pillars:

### 1. **Registry** (`src/registry/`)
The core ownership layer managing domain records, subdomains, and authorizations.

### 2. **Registrar** (`src/registrar/`)
Handles domain registration logic, pricing calculations, and renewal management.

### 3. **Resolver** (`src/resolver/`)
Maps domains to blockchain data — addresses, content, ABIs, and custom records.

### 4. **Auction House** (`src/auction/`)
English auction system for fair distribution of premium domains.

---

## 💎 Smart Contracts Overview

### Key Contracts

| Contract | Purpose |
|----------|---------|
| **LitNamesRegistry** | Core registry for domain ownership and delegation |
| **BaseRegistrar** | ERC721-based domain registration and management |
| **PriceOracle** | Dynamic pricing with Pyth Network integration |
| **LitAuctionHouse** | Auction mechanism for premium domain sales |
| **LitDefaultResolver** | Multi-profile resolver for domain resolution |

### Pricing Structure

Domain prices are based on length (in USD):

- 1 character: **$420** / year
- 2 characters:  **$269** / year
- 3 characters: **$169** / year
- 4 characters: **$69** / year
- 5+ characters: **$25** / year

**Multi-year discounts:**
- 1 year: 0%
- 2 years: 5%
- 3 years: 15%
- 4 years: 30%
- 5+ years: 40%

---

## 🛠️ Tech Stack

- **Solidity ^0.8.x** — Smart contract language
- **Foundry** — Development framework and testing suite
- **OpenZeppelin** — Security-audited contract libraries
- **Pyth Network** — Real-time price feeds
- **ethers.js** — Web3 interaction library

---

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Node.js v16+ and npm

### Installation

```bash
# Clone the repository
git clone https://github.com/Litnames/lit-domains-contracts.git
cd lit-domains-contracts

# Install dependencies
forge install
npm install
```

### Build

```bash
# Compile contracts
forge build

# Run tests
forge test

# Run tests with verbosity
forge test -vvv
```

### Deploy

```bash
# Deploy to local network
forge script script/Deploy. s.sol --rpc-url localhost --broadcast

# Deploy to testnet
forge script script/Deploy. s.sol --rpc-url <your-rpc-url> --broadcast --verify
```

---

## 🧪 Development

### Project Structure

```
lit-domains-contracts/
├── src/
│   ├── auction/          # Auction house contracts
│   ├── registrar/        # Registration & pricing logic
│   ├── registry/         # Core ownership registry
│   ├── resolver/         # Domain resolution profiles
│   └── utils/            # Helper contracts & libraries
├── test/                 # Test suites
├── script/               # Deployment scripts
└── lib/                  # Dependencies
```

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
forge test --match-path test/Registry.t.sol

# Generate gas report
forge test --gas-report
```

### Code Coverage

```bash
forge coverage
```

---

## 🔐 Security

This project uses:

- **ReentrancyGuard** for protection against reentrancy attacks
- **Ownable** for access control
- **Pausable** for emergency stops
- **OpenZeppelin** audited libraries

**Note:** These contracts are under active development. Use at your own risk in production environments.

---

## 📜 License

This project is open source and available under the terms specified in the repository. 

---

## 🤝 Contributing

Contributions are welcome! Whether it's: 

- 🐛 Bug reports
- 💡 Feature requests
- 📝 Documentation improvements
- 🔧 Code contributions

Feel free to open an issue or submit a pull request. 

---

## 🎯 Roadmap

- [ ] Multi-chain support
- [ ] Subdomain marketplace
- [ ] ENS compatibility layer
- [ ] Advanced resolver profiles
- [ ] Governance token integration
- [ ] Mobile SDK

---

## 💬 Community

Join the conversation and stay updated with Lit Domains development. 

---

## 🙏 Acknowledgments

Built with support from:
- OpenZeppelin for security libraries
- Foundry for development tools
- Pyth Network for price oracles
- The Lit Protocol ecosystem

---

**Made with 🔥 by the Lit Domains team**