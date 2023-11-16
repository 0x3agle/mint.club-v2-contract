# Mint Club V2
The inherited token creator employs a bonding curve to generate new tokens using base tokens as collateral

## Contract addresses 📜
### Ethereum Sepolia Testnet
- MCV2_Token: [0x469F0c719bbD71686087dF42336E208617a7AD77](https://sepolia.etherscan.io/address/0x469F0c719bbD71686087dF42336E208617a7AD77#code)
- MCV2_MultiToken: [0xa26Ed6D99696408cb12f3490F9A12F8E4A580cFc](https://sepolia.etherscan.io/address/0xa26Ed6D99696408cb12f3490F9A12F8E4A580cFc#code)
- MCV2_Bond: [0x9e32d918CD91989C70C9c36F7ea66Df03f9fa864](https://sepolia.etherscan.io/address/0x9e32d918CD91989C70C9c36F7ea66Df03f9fa864#code)
- Locker: [0xA5f922Ce1992665B4B93D1Ee32BFb6C33F513550](https://sepolia.etherscan.io/address/0xA5f922Ce1992665B4B93D1Ee32BFb6C33F513550#code)
- MerkleDistributor: [0x8F4C6Bc7B47D9d54b4B698Dc5DE1D087386f4161](https://sepolia.etherscan.io/address/0x8F4C6Bc7B47D9d54b4B698Dc5DE1D087386f4161#code)

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
 contracts/             |      100 |    89.15 |      100 |    99.71 |                |
  Locker.sol            |      100 |      100 |      100 |      100 |                |
  MCV2_Bond.sol         |      100 |     90.2 |      100 |    99.43 |            238 |
  MCV2_ICommonToken.sol |      100 |      100 |      100 |      100 |                |
  MCV2_MultiToken.sol   |      100 |    58.33 |      100 |      100 |                |
  MCV2_Royalty.sol      |      100 |      100 |      100 |      100 |                |
  MCV2_Token.sol        |      100 |       50 |      100 |      100 |                |
  MerkleDistributor.sol |      100 |    92.31 |      100 |      100 |                |
------------------------|----------|----------|----------|----------|----------------|
All files               |      100 |    89.15 |      100 |    99.71 |                |
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
|  Methods                                          ·                15 gwei/gas                ·       2050.40 usd/eth       │
······················|·····························|·············|·············|···············|···············|··············
|  Contract           ·  Method                     ·  Min        ·  Max        ·  Avg          ·  # calls      ·  usd (avg)  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  createLockUp               ·     118348  ·     176962  ·       147517  ·           40  ·       4.54  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  unlock                     ·      65443  ·      66700  ·        66002  ·            9  ·       2.03  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  burn                       ·      89576  ·     128860  ·       110769  ·           42  ·       3.41  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  claimRoyalties             ·          -  ·          -  ·        80118  ·            3  ·       2.46  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createMultiToken           ·     388382  ·     489607  ·       484253  ·           87  ·      14.89  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createToken                ·     292616  ·     521850  ·       506000  ·          111  ·      15.56  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  mint                       ·     104331  ·     210070  ·       186498  ·           96  ·       5.74  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateBondCreator          ·      28439  ·      31251  ·        30312  ·           12  ·       0.93  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateProtocolBeneficiary  ·          -  ·          -  ·        28995  ·            1  ·       0.89  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_MultiToken    ·  safeTransferFrom           ·          -  ·          -  ·        37867  ·            1  ·       1.16  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_MultiToken    ·  setApprovalForAll          ·          -  ·          -  ·        48789  ·           20  ·       1.50  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Token         ·  approve                    ·      49012  ·      49312  ·        49210  ·           29  ·       1.51  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Token         ·  transfer                   ·          -  ·          -  ·        32258  ·            1  ·       0.99  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  claim                      ·      91728  ·      97832  ·        95802  ·           30  ·       2.95  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  createDistribution         ·     140040  ·     203788  ·       188380  ·           67  ·       5.79  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  refund                     ·      47640  ·      48950  ·        48295  ·            6  ·       1.49  │
······················|·····························|·············|·············|···············|···············|··············
|  TaxToken           ·  approve                    ·          -  ·          -  ·        46634  ·            4  ·       1.43  │
······················|·····························|·············|·············|···············|···············|··············
|  TaxToken           ·  transfer                   ·          -  ·          -  ·        54349  ·            4  ·       1.67  │
······················|·····························|·············|·············|···············|···············|··············
|  TestMultiToken     ·  setApprovalForAll          ·      26214  ·      46114  ·        45511  ·           33  ·       1.40  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  approve                    ·      24327  ·      46611  ·        46039  ·          162  ·       1.42  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  transfer                   ·      34354  ·      51490  ·        50441  ·          111  ·       1.55  │
······················|·····························|·············|·············|···············|···············|··············
|  Deployments                                      ·                                           ·  % of limit   ·             │
····················································|·············|·············|···············|···············|··············
|  Locker                                           ·          -  ·          -  ·      1245380  ·        4.2 %  ·      38.30  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Bond                                        ·    4139945  ·    4139969  ·      4139953  ·       13.8 %  ·     127.33  │
····················································|·············|·············|···············|···············|··············
|  MCV2_MultiToken                                  ·          -  ·          -  ·      1776148  ·        5.9 %  ·      54.63  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Token                                       ·          -  ·          -  ·       850499  ·        2.8 %  ·      26.16  │
····················································|·············|·············|···············|···············|··············
|  MerkleDistributor                                ·          -  ·          -  ·      1971110  ·        6.6 %  ·      60.62  │
····················································|·············|·············|···············|···············|··············
|  TaxToken                                         ·          -  ·          -  ·       736527  ·        2.5 %  ·      22.65  │
····················································|·············|·············|···············|···············|··············
|  TestMultiToken                                   ·    1380918  ·    1380930  ·      1380924  ·        4.6 %  ·      42.47  │
····················································|·············|·············|···············|···············|··············
|  TestToken                                        ·     659419  ·     679683  ·       678180  ·        2.3 %  ·      20.86  │
·---------------------------------------------------|-------------|-------------|---------------|---------------|-------------·
```
