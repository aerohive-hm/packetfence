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
        
        let contentHtml=[];
        for(let i=0;i<content.length;i++){
            contentHtml.push(
                <div className="guidance-content-div-guidance">
                    {content[i]}
                </div>
            );
        }
        return(

            <div className="guidance-div-guidance">
                <div className="guidance-title-div-guidance">
                    {title}
                </div>
                {contentHtml}
                <div className="clear-float-div-common" ></div >
            </div>


        )
    }
}

export default guidance;