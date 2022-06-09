import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-waffle"
import * as dotenv from "dotenv"
import "hardhat-gas-reporter"
import "hardhat-dependency-compiler"
import { HardhatUserConfig } from "hardhat/config"
import "./tasks/deploy"

dotenv.config()

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
    solidity: "0.8.4",
    dependencyCompiler: {
        paths: ["@semaphore-protocol/contracts/verifiers/Verifier20.sol"]
    },
    networks: {
        ropsten: {
            url: process.env.ROPSTEN_URL || "",
            accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
        },
        harmony: {
            url: `${process.env.HARMONY_MAINNET_URL}`,
            accounts: [`0x${process.env.PRIVATE_KEY}`]
        },
        harmony_testnet: {
            url: `${process.env.HARMONY_TESTNET_URL}`,
            accounts: [`0x${process.env.PRIVATE_KEY}`]
        }
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD"
    }
}

export default config
