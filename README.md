# Mint Club V2
The inherited token creator employs a bonding curve to generate new tokens using base tokens as collateral

## Contract addresses 📜
### Ethereum Sepolia Testnet
- MCV2_Token: [0xAbd0087147958a164BCb41e7aD8Ee4a4af57b4a2](https://sepolia.etherscan.io/address/0xAbd0087147958a164BCb41e7aD8Ee4a4af57b4a2#code)
- MCV2_MultiToken: [0xCFe883f228822214fC82868Cd5d4Cf6Df72699b2](https://sepolia.etherscan.io/address/0xCFe883f228822214fC82868Cd5d4Cf6Df72699b2#code)
- MCV2_Bond: [0x794B9BC9c7316487D9fb31B6eEB8b9b57d958c3D](https://sepolia.etherscan.io/address/0x794B9BC9c7316487D9fb31B6eEB8b9b57d958c3D#code)
- Locker: [0xD77AeD25FC2CE8F425c9a0d65c823EdA32531d1d](https://sepolia.etherscan.io/address/0xD77AeD25FC2CE8F425c9a0d65c823EdA32531d1d#code)
- MerkleDistributor: [0x94792B59D2f1a9051Af2c27482FfB095eE4ba084](https://sepolia.etherscan.io/address/0x94792B59D2f1a9051Af2c27482FfB095eE4ba084#code)

## Design Choices 📐

### Discrete Bonding Curve (DBC)
Unlike Mint Club V1's linear bonding curve (`y = x` -> `total supply = token price`), the V2 contract uses a custom increasing price step array for the following reasons:
1. Utilizing `y = ax^b` bonding curves is challenging to test because we have to use approximation to calculate the power function of `(_baseN / _baseD) ^ (_expN / _expD)` ([Reference: Banchor's Bonding Curve implementation](https://github.com/relevant-community/bonding-curve/blob/master/contracts/Power.sol))
2. Employing a single bonding curve is hard to customize. Supporting various types of curve functions (e.g., Sigmoid, Logarithm, etc) might be too difficult to implement in Solidity, or even impossible in many cases
3. Therefore, we decided to use an array of price steps (called `BondStep[] { rangeTo, price }`), that is simple to calculate and fully customizable.

#### An example of a price step array:
![image](https://i.imgur.com/FVhTsk4.png)

Parameters example:
- stepRanges: [ 1000, 10000, 500000, 1000000, ..., 21000000 ]
- stepPrices: [ 0, 1, 2, 4, ..., 100 ]

### Custom ERC20 Tokens as Reserve Tokens
Some ERC20 tokens incorporate tax or rebasing functionalities, which could lead to unforeseen behaviors in our Bond contract. For instance, a taxed token might result in the undercollateralization of the reserve token, preventing the complete refund of minted tokens from the bond contract. A similar scenario could occur with Rebase Tokens, as they are capable of altering the balance within the Bond contract.

Due to the diverse nature of custom cases, it is impractical for our bond contract to address all of them. Therefore, we have chosen not to handle these cases explicitly. It's important to note that any behavior stemming from the custom ERC20 token is not considered a bug, as it is a consequence of the token's inherent code.

We plan to issue warnings on our official front-end for tokens known to potentially disrupt our bond contract. However, **it's crucial for users to conduct their own research and understand the potential implications of selecting a specific reserve token.**

## Run Tests 🧪
```bash
npx hardhat test
```

### Coverage ☂️
```m
------------------------|----------|----------|----------|----------|----------------|
File                    |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
------------------------|----------|----------|----------|----------|----------------|
 contracts/             |      100 |    90.09 |      100 |    99.72 |                |
  Locker.sol            |      100 |      100 |      100 |      100 |                |
  MCV2_Bond.sol         |      100 |    92.16 |      100 |    99.46 |            263 |
  MCV2_ICommonToken.sol |      100 |      100 |      100 |      100 |                |
  MCV2_MultiToken.sol   |      100 |    58.33 |      100 |      100 |                |
  MCV2_Royalty.sol      |      100 |      100 |      100 |      100 |                |
  MCV2_Token.sol        |      100 |       50 |      100 |      100 |                |
  MerkleDistributor.sol |      100 |    92.31 |      100 |      100 |                |
------------------------|----------|----------|----------|----------|----------------|
All files               |      100 |    90.09 |      100 |    99.72 |                |
------------------------|----------|----------|----------|----------|----------------|
```

## Deploy 🚀
```bash
npx hardhat compile && HARDHAT_NETWORK=ethsepolia node scripts/deploy.js
```

## Gas Consumption ⛽️
```m
·---------------------------------------------------|---------------------------|---------------|-----------------------------·
|               Solc version: 0.8.20                ·  Optimizer enabled: true  ·  Runs: 50000  ·  Block limit: 30000000 gas  │
····················································|···························|···············|······························
|  Methods                                          ·                15 gwei/gas                ·       2017.21 usd/eth       │
······················|·····························|·············|·············|···············|···············|··············
|  Contract           ·  Method                     ·  Min        ·  Max        ·  Avg          ·  # calls      ·  usd (avg)  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  createLockUp               ·     118348  ·     176962  ·       147517  ·           40  ·       4.46  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  unlock                     ·      65443  ·      66700  ·        66002  ·            9  ·       2.00  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  burn                       ·      89620  ·     128860  ·       110788  ·           42  ·       3.35  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  claimRoyalties             ·          -  ·          -  ·        80052  ·            3  ·       2.42  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createMultiToken           ·     388552  ·     489755  ·       484463  ·           88  ·      14.66  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createToken                ·     292638  ·     521872  ·       506705  ·          116  ·      15.33  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  mint                       ·     104331  ·     210070  ·       186507  ·           96  ·       5.64  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateBondCreator          ·      26227  ·      29039  ·        28171  ·           13  ·       0.85  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateProtocolBeneficiary  ·          -  ·          -  ·        28995  ·            1  ·       0.88  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateTokenMetaData        ·      39956  ·     118858  ·       106719  ·           13  ·       3.23  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_MultiToken    ·  safeTransferFrom           ·          -  ·          -  ·        37867  ·            1  ·       1.15  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_MultiToken    ·  setApprovalForAll          ·          -  ·          -  ·        48856  ·           20  ·       1.48  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Token         ·  approve                    ·      49012  ·      49312  ·        49210  ·           29  ·       1.49  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Token         ·  transfer                   ·          -  ·          -  ·        32258  ·            1  ·       0.98  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  claim                      ·      91728  ·      97832  ·        95802  ·           30  ·       2.90  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  createDistribution         ·     140040  ·     203788  ·       188380  ·           67  ·       5.70  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  refund                     ·      47640  ·      48950  ·        48295  ·            6  ·       1.46  │
······················|·····························|·············|·············|···············|···············|··············
|  TaxToken           ·  approve                    ·          -  ·          -  ·        46634  ·            4  ·       1.41  │
······················|·····························|·············|·············|···············|···············|··············
|  TaxToken           ·  transfer                   ·          -  ·          -  ·        54349  ·            4  ·       1.64  │
······················|·····························|·············|·············|···············|···············|··············
|  TestMultiToken     ·  setApprovalForAll          ·      26214  ·      46114  ·        45511  ·           33  ·       1.38  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  approve                    ·      24327  ·      46611  ·        46039  ·          162  ·       1.39  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  transfer                   ·      34354  ·      51490  ·        50441  ·          111  ·       1.53  │
······················|·····························|·············|·············|···············|···············|··············
|  Deployments                                      ·                                           ·  % of limit   ·             │
····················································|·············|·············|···············|···············|··············
|  Locker                                           ·          -  ·          -  ·      1245380  ·        4.2 %  ·      37.68  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Bond                                        ·    4516983  ·    4517007  ·      4516991  ·       15.1 %  ·     136.68  │
····················································|·············|·············|···············|···············|··············
|  MCV2_MultiToken                                  ·          -  ·          -  ·      1943653  ·        6.5 %  ·      58.81  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Token                                       ·          -  ·          -  ·       850499  ·        2.8 %  ·      25.73  │
····················································|·············|·············|···············|···············|··············
|  MerkleDistributor                                ·          -  ·          -  ·      1971110  ·        6.6 %  ·      59.64  │
····················································|·············|·············|···············|···············|··············
|  TaxToken                                         ·          -  ·          -  ·       736527  ·        2.5 %  ·      22.29  │
····················································|·············|·············|···············|···············|··············
|  TestMultiToken                                   ·    1380918  ·    1380930  ·      1380924  ·        4.6 %  ·      41.78  │
····················································|·············|·············|···············|···············|··············
|  TestToken                                        ·     659419  ·     679683  ·       678180  ·        2.3 %  ·      20.52  │
·---------------------------------------------------|-------------|-------------|---------------|---------------|-------------·
```
