import React from 'react';
import { ethers } from "ethers";
import TokenArtifact from "./contracts/LanguageModelVerifier.json";
import contractAddress from "./contracts/contract-address.json";

function getColor(context, x, y) {    
  
  var pixel = context.getImageData(x, y, 1, 1);

  // Red = rgb[0], green = rgb[1], blue = rgb[2]
  // All colors are within range [0, 255]
  var rgb = pixel.data;
  return rgb;
}
function nromalizeChannel(c, mean, std){
  /*
  var total = 0.0;
  for (var h = 0; h <  c.length; h++){
    for(var w = 0; w < c[h].length; w++){
      total += c[h][w];
    }
  }
  var mean = total / (c.length * c[0].length);
  var square_sum = 0;  
  for (var h = 0; h <  c.length; h++){
    for(var w = 0; w < c[h].length; w++){
      square_sum += (c[h][w] - mean) * (c[h][w] - mean);
    }
  }
  square_sum / (c.length * c[0].length);
  */
  for (var h = 0; h <  c.length; h++){
    for(var w = 0; w < c[h].length; w++){
      c[h][w] = (c[h][w]) / 255 * 100;
      c[h][w] = parseInt(c[h][w]);
      //Math.floor(c[h][w] = (c[h][w] - mean) / std);
      //c[h][w] += 100;
    }
  }
}
function getRGB(canvas){
  var context = canvas.getContext("2d");
  var r = [];
  var g = [];
  var b = [];
  for (var h = 0; h < canvas.height; h++){
    r.push([]);
    g.push([]);
    b.push([]);
    for (var w = 0; w < canvas.width; w++){
      var rgb = getColor(context, w, h);
      r[h].push(rgb[0]);
      g[h].push(rgb[1]);
      b[h].push(rgb[2]);
    }
  }

  nromalizeChannel(r, 0.485, 0.229);
  nromalizeChannel(g, 0.456, 0.224);
  nromalizeChannel(b, 0.406, 0.225);
  return [r, g, b];
}



class ZKHotDog extends React.Component {
    constructor(props){
      super(props);
      this.imageCanvasRef = React.createRef();
      this.hotdogParagraphRef = React.createRef();
      this.fileInput = React.createRef();
      this.handleNewImage = this.handleNewImage.bind(this);
      this.drawImages = this.drawImages.bind(this);
      this.checkProof = this.checkProof.bind(this);
      this.state = {hotdog: 0, nothotdog: 0, zk_result: false};
    }

    async _initializeEthers() {
      // We first initialize ethers by creating a provider using window.ethereum
      this._provider = new ethers.providers.Web3Provider(window.ethereum);
      //await this._provider.send('eth_requestAccounts', []); // <- this promps user to connect metamask

  
      // Then, we initialize the contract using that provider and the token's
      // artifact. You can do this same thing with your contracts.
      this._token = new ethers.Contract(
        contractAddress.Hotdog,
        TokenArtifact.abi,
        this._provider.getSigner(0)
      );
    }

    async componentDidMount() {
      await this._initializeEthers();
      this.drawImages('/upload.png');
    }

    handleNewImage(e){
      const reader = new FileReader(e.target.files[0]);
      reader.onload = (e) => {
        //Loading the file is async, using thise hook to update
        //state is the best way around it
        this.drawImages(reader.result);
    };
    reader.readAsDataURL(e.target.files[0])
      
    }

    drawImages(url){
      console.log("drawing");
      var image = new Image();
      image.src = url;
      image.width = "20";
      image.height  = "20";
      image.onload = () => {

        const imageContext = this.imageCanvasRef.current.getContext('2d');
        imageContext.drawImage(image, 0, 0, 20, 20);

        console.log(getRGB(this.imageCanvasRef.current));
    };
      

    }


    circomToReal(num) {
      const substr_p = 186575808495617
      var str_num = String(num)
      var substr_num = parseInt(str_num.substring(str_num.length - 15, str_num.length));
      return substr_num - substr_p;
  }   

    async checkProof(){
      console.log("Checking proof"); 
      const snarkjs = window.snarkjs;
        console.log('Generating proof. SnarkJS:', snarkjs);

      let wasmFile = "/hotdog_model/hotdog_model.wasm";
	    let zkeyFile = "/hotdog_model/hotdog_model.zkey";
      let rgb = getRGB(this.imageCanvasRef.current);
	    
      const { proof, publicSignals } = await snarkjs.groth16.fullProve({
             "in": rgb},
            wasmFile,
            zkeyFile);
      console.log('Finished generation')
      console.log(proof);
      console.log(publicSignals);
      var p_0 = parseInt(publicSignals[0] > 10000000000000 ? this.circomToReal(publicSignals[0]) : publicSignals[0]);
      var p_1 = parseInt(publicSignals[1] > 10000000000000 ? this.circomToReal(publicSignals[1]) : publicSignals[1]);
      
      const result = await this._token.verifyProof([proof.pi_a[0], proof.pi_a[1]], [
        [proof.pi_b[0][1], proof.pi_b[0][0]], [proof.pi_b[1][1], proof.pi_b[1][0]]], 
        [proof.pi_c[0], proof.pi_c[1]], publicSignals);
      console.log(result);
      this.setState({hotdog: p_0, nothotdog: p_1, zk_result: result});

    
    //const res = await snarkjs.groth16.verify(vkey, publicSignals, proof);
    
        //const vkey = await fetch("/language_model/vkey.json").then( function(res) {
        //     return res.json();
        //});

      
      //const res = await snarkjs.groth16.verify(vkey, publicSignals, proof);
      //console.log(res);
    }

  
    render() {

      return (
        <div className="MarkdownEditor">
            <h1>Upload your Hotdog</h1>
            
            <input type="file" name="Upload File" ref={this.fileInput} accept="image/*" onChange={this.handleNewImage} style={{ display: 'none' }}/>
            <button onClick={() => this.fileInput.current.click()} style={{ color: 'white', fontSize: '20px', backgroundColor: 'black', cursor: 'pointer', padding: '10px 60px', borderRadius: '5px', margin: '10px 10px'}} >Choose File</button>
            <p></p>
            <canvas ref={this.imageCanvasRef} width="20" height="20"/>
            <p ref={this.hotdogParagraphRef}>I do not know if this is a hotdog</p>
            
            
            <button onClick={this.checkProof} style={{ color: 'white', fontSize: '20px', backgroundColor: 'black', cursor: 'pointer', padding: '10px 60px', borderRadius: '5px', margin: '10px 0px'}}>Generate proof</button>
            
            <h1>Hotdog Alpha Analysis</h1>
            <p>Hotdog Score</p>
            <h1>{this.state.hotdog}</h1>

            <p>Not-Hotdog Score</p>
            <h1>{this.state.nothotdog}</h1>

            <p>Do I have a good-looking hotdog?</p>
            <h1>{this.state.hotdog > this.state.nothotdog ? "YES" : "NO"}  </h1>

            <p></p>
            <p>ZK Verification</p>
            <h1> {this.state.zk_result ? "True" : "False"} </h1>
        </div>
      );
      /* <canvas height="200" width="200" image={image}/>
      if (this.state.url == null){
        return (
          <div className="MarkdownEditor">
              <input type="file" name="Upload File" accept="image/*" onChange={this.handleNewImage}/>
          </div>
        );
      } else {
        return (
          <div className="MarkdownEditor">
              <input type="file" name="Upload File" accept="image/*" onChange={this.handleNewImage}/>
          </div>
        );
      }
    */
    }
    
  }

  export default ZKHotDog;

  //  <div>
	//  <button onClick={this.handleSubmission}>Submit</button>
	//  </div>