# 🔗 Blockchain-Based CV/Resume System

An immutable, decentralized CV/Resume system built on the Stacks blockchain using Clarity smart contracts. Create tamper-proof professional profiles with verifiable work history, education, skills, and certifications.

## ✨ Features

- 👤 **Immutable Profiles**: Create permanent professional profiles on the blockchain
- 💼 **Work Experience Tracking**: Add and verify employment history
- 🎓 **Education Records**: Store and validate educational achievements
- 🛠️ **Skills Management**: Showcase skills with peer endorsements
- 📜 **Certifications**: Add professional certifications with verification
- ✅ **Verification System**: Trusted verifiers can validate profile information
- 🤝 **Peer Endorsements**: Get skills endorsed by other professionals

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Stacks Wallet](https://wallet.hiro.so/) for testnet interaction

### Installation

```bash
git clone https://github.com/tambawuri5/Blockchain-Based-CV-Resume-System.git
cd Blockchain-Based-CV-Resume-System
clarinet console
```

## 📋 Contract Functions

### Profile Management

#### Create Profile
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System create-profile 
  "John Doe" 
  "Senior Developer" 
  "john@example.com" 
  "+1234567890" 
  "San Francisco, CA" 
  "Experienced developer with 5+ years in blockchain")
```

#### Update Profile
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System update-profile 
  "John Doe" 
  "Lead Developer" 
  "john.doe@newcompany.com" 
  "+1234567890" 
  "Austin, TX" 
  "Lead developer specializing in DeFi protocols")
```

### Work Experience

#### Add Work Experience
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System add-work-experience 
  "TechCorp Inc" 
  "Senior Developer" 
  u202301 
  (some u202312) 
  "Led development of DeFi trading platform")
```

### Education

#### Add Education Record
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System add-education 
  "MIT" 
  "Computer Science" 
  "Blockchain Technology" 
  u201901 
  u202305 
  (some "3.8"))
```

### Skills & Endorsements

#### Add Skill
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System add-skill 
  "Solidity" 
  u9)
```

#### Endorse Someone's Skill
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System endorse-skill 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE 
  "Solidity")
```

### Certifications

#### Add Certification
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System add-certification 
  "Certified Blockchain Developer" 
  "Blockchain Institute" 
  u202301 
  (some u202501) 
  "CBD-12345")
```

## 🔍 Read Functions

### Get Profile Information
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System get-profile 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
(contract-call? .Blockchain-Based-CV-Resume-System get-work-experience 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
(contract-call? .Blockchain-Based-CV-Resume-System get-education 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
(contract-call? .Blockchain-Based-CV-Resume-System get-skill 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
(contract-call? .Blockchain-Based-CV-Resume-System get-certification 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

### Get Statistics
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System get-total-users)
(contract-call? .Blockchain-Based-CV-Resume-System get-total-verifications)
```

## 🔐 Verification System

Only contract owner can add verifiers:
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System add-verifier 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

Verifiers can validate profiles:
```clarity
(contract-call? .Blockchain-Based-CV-Resume-System verify-profile 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

## 🧪 Testing

```bash
clarinet test
```

## 📊 Data Structure

### Profile
- Name, title, contact information
- Professional summary
- Creation timestamp
- Verification status

### Work Experience
- Company, position, dates
- Job description
- Optional verification by employers

### Education
- Institution, degree, field of study
- Dates, GPA (optional)
- Verification tracking

### Skills
- Skill name and proficiency level (1-10)
- Endorsement count and endorsers
- Creation timestamp

### Certifications
- Certificate details and issuer
- Issue/expiry dates
- Verification status

## 🌐 Deployment

Deploy to testnet:
```bash
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

Deploy to mainnet:
```bash
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)

---

Built with ❤️ on Stacks blockchain
