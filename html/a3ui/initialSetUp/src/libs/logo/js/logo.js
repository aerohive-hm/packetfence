/**
 * Created by mengjiuxiang on 2017/4/14.
 */


import React from 'react';
import { Table ,Row} from 'antd';
import '../css/logo.css';

import logoImg from '../../../media/logo.svg';

const {
    Component
} = React;


class logo extends Component {
    constructor(props){
        super(props);
        this.state = {

        };
    };

    render(){
        const {} = this.props;
        return(

            <div className="title-screen-full-div-logo">
                <div className="title-screen-center-div-logo">
                    <div className="logo-div-logo" >
                        <img className="logo-img-logo" src={logoImg} />
                    </div>
                    <div className="text-div-logo" >
                        A3 Setup
                    </div>

                </div>
            </div>


        )
    }
}

export default logo;