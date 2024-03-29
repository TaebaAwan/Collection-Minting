const path = require("path");
require('dotenv').config();
const fs = require("fs");
const axios = require("axios");
const FormData = require("form-data");

const PinImageToIpfs = async (filePath, filename) => {
  const pinataEndpoint = "https://api.pinata.cloud/pinning/pinFileToIPFS";
  const pinataApiKey = process.env.APIkey;
  const pinataApiSecret = process.env.APIsecret;

  const form_data = new FormData();
  try {
    form_data.append("file", fs.createReadStream(`${filePath}//${filename}`));

    const request = {
      method: "post",
      url: pinataEndpoint,
      maxContentLength: "Infinity",
      headers: {
        pinata_api_key: pinataApiKey,
        pinata_secret_api_key: pinataApiSecret,
        "Content-Type": `multipart/form-data; boundary=${form_data._boundary}`,
      },
      data: form_data,
    };


   const response = await axios(request);
   const imageHash= response.data.IpfsHash;
      console.log(imageHash);
      let str = filename;
      const Name = str.slice(0, -4);
  

      metaData = {
        description:
          "There's art everywhere!",
        image: "https://ipfs.io/ipfs/" + imageHash,
        name: `${Name}`,
        attributes: [
          {
            trait_type: "Abstract",
            value: "Grudge",
          },
          {
            display_type: "Emotions",
            trait_type: "Sensation",
            value: 40,
          },
          {
            display_type: "Attachment",
            trait_type: "Way of Expression",
            trait_type: "Belonging",
          },
          {
            display_type: "Deja Vu",
            trait_type: "Reminiscence",
            value: 5.5,
       },
     ],
      };

      const metadataJson = JSON.stringify(metaData);

      await fs.writeFile(
        path.join(__dirname, `../Metadata/${Name}.json`),
        metadataJson,
        "utf8",
        function (err) {
          if (err) {
            console.log("An error occured while writing JSON Object to File.");
            return console.log(err);
          } else {
            console.log("JSON file has been saved to " + `Metadata/${Name}`);
          }
        }
      );
  
      const getMetaDataJson = path.join(__dirname, `../Metadata/${Name}.json`);
      const form_meta_data = new FormData();
      try {
        form_meta_data.append("file", fs.createReadStream(getMetaDataJson));
        const request = {
          method: "post",
          url: pinataEndpoint,
          maxContentLength: "Infinity",
          headers: {
            pinata_api_key: pinataApiKey,
            pinata_secret_api_key: pinataApiSecret,
            "Content-Type": `multipart/form-data; boundary=${form_meta_data._boundary}`,
          },
          data: form_meta_data,
        };
  
        const response = await axios(request);
        console.log(response.data.IpfsHash);
      } catch (err) {
        console.log(err);
      }
    } catch (err) {
      console.log(err);
    }
  };
  
  module.exports = {
    PinImageToIpfs,
  };

 // image hash:  QmTNrhCGUSFh78GZPayBqCavt7GS1ZHgAogjqNqjcdr4GG
 // 

 //metadata hash: Qmec2mrgKf93pCkgRJrN56kiB6vuPgyeAyrTdJK9QiByDf
