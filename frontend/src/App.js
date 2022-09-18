import logo from './logo.svg';
import './App.css';
import './ZKInsult';
import ZKInsult from './ZKInsult';
import ZKHotDog from './ZKHotDog';
import HomePage from './HomePage';
//import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path='/' element={<HomePage />}/>
          <Route path='/zk-insult' element={<ZKInsult />}/>
          <Route path='/zk-hotdog' element={<ZKHotDog />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
