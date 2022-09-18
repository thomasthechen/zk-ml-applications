
import { Link } from 'react-router-dom';
import React from 'react';
import styled from "styled-components";

const Button = styled.button`
  background-color: black;
  color: white;
  font-size: 20px;
  padding: 10px 60px;
  border-radius: 5px;
  margin: 10px 0px;
  cursor: pointer;
`;

class HomePage extends React.Component {
    render() {
        return(
            <div>
                <h1> Useful ZK-ML Applications </h1>
                <h3> I want to prove that... </h3>
                <Link to='/zk-insult'>
                    <Button className='button'>
                        I have a good insult
                    </Button>
                </Link>
                <p></p>
                <Link to='/zk-hotdog'>
                    <Button className='button'>
                        I have a good hotdog
                    </Button>
                </Link>
            </div>
        )
    }
}
export default HomePage;

