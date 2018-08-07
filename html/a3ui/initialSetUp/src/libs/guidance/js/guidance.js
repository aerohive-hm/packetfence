/**
 * Created by mengjiuxiang on 2017/4/14.
 */


import React from 'react';
import { Table ,Row} from 'antd';
import '../css/guidance.css';

const {
    Component
} = React;


class guidance extends Component {
    constructor(props){
        super(props);
        this.state = {

        };
    };

    render(){
        const {title,content} = this.props;
        return(

            <div className="guidance-div-guidance">
                <div className="guidance-title-div-guidance">
                    {title}
                </div>
                <div className="guidance-content-div-guidance">
                    {content}
                </div>
                <div className="clear-float-div-common" ></div >
            </div>


        )
    }
}

export default guidance;