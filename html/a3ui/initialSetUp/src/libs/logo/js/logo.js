/**
 * Created by mengjiuxiang on 2017/4/14.
 */


import React from 'react';
import { Table ,Row} from 'antd';
import '../css/logo.css';

import logoImg from '../../../media/logo.svg';

import {i18nfr} from "../../../i18n/logo/nls/fr/logo";
import {i18n} from "../../../i18n/logo/nls/logo";

const {
    Component
} = React;


class logo extends Component {
    constructor(props){
        super(props);
        this.state = {
            i18n:{},

        };
    };

    componentDidMount() {
        let self=this;
        self.getRightI18n();
    }

    getRightI18n= () => {
        let self=this;
        let navigatorLanguage = navigator.language||navigator.userLanguage;
        let rightI18n;

        navigatorLanguage = navigatorLanguage.substr(0, 2);

        if(navigatorLanguage==="fr"){
            rightI18n=i18nfr;
        }else{
            rightI18n=i18n;
        }
        self.setState({
            i18n : rightI18n,
        })
    }

    render(){
        const {} = this.props;
        let self=this;

        document.title = self.state.i18n.a3Setup;

        return(

            <div className="title-screen-full-div-logo">
                <div className="title-screen-center-div-logo">
                    <div className="logo-div-logo" >
                        <img className="logo-img-logo" src={logoImg} />
                    </div>
                    <div className="text-div-logo" >
                        {self.state.i18n.a3Setup}
                    </div>

                </div>
            </div>


        )
    }
}

export default logo;
