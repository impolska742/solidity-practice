const ethers = require("ethers");

const createBytes = (args) => {
  const name = args[0];
  const bytes = ethers.utils.formatBytes32String(name);

  console.log("Bytes : ", bytes);
};

createBytes(process.argv.slice(2));

// ["0x526168756c000000000000000000000000000000000000000000000000000000", "0x4e6172656e647261000000000000000000000000000000000000000000000000"]
