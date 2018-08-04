import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/networksCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/networksCtl";
import {i18n} from "../../i18n/ctlComponents/nls/networksCtl";

import networksImg from "../../media/networks.png";



const {Component} = React;

class networksCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                hostnameWrongMessage:"",
            },
            enableClustering:true,
            loading:false,
            dataTable:[],
        };


    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();
        self.getData();
    }

    getRightI18n= () => {
        let self=this;
        let localeForLicenseInfo=window.localStorage.getItem('getStart');
        let rightI18n;
        if(localeForLicenseInfo==="fr"){
            rightI18n=i18nfr;
        }else{
            rightI18n=i18n;
        }
        self.setState({
            i18n : rightI18n,
        })

    }

    getData= () => {
        let self=this;

        let url= "/a3/api/v1/configurator/networks";
         
        let param={
        }
        
        self.setState({
            loading : true,
        })

        // new RequestApi('get',url,param,xCsrfToken,(data)=>{
        //     self.getTureData(data);
        // });

        self.getTureData(mock.networks);
    }

    getTureData= (data) => {
        let self=this;
        let dataTable=data.items;
        for(let i=0;i<dataTable.length;i++){
            dataTable[i].key=dataTable[i].id;
            dataTable[i].vlan=dataTable[i].id;
        }
        self.setState({
            dataTable: dataTable,
            loading : false,
        }); 
    }


    onChangeCheckbox=(e)=>{
        let self=this;
        this.setState({
            enableClustering: e.target.checked,
        });
    }

    onBlurCheckHostname(e){
        let self=this;
        self.checkHostname(e.target.value);
    }

    checkHostname=(hostname)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!hostname||hostname.toString().trim()===""){
            newWrongMessage.hostnameWrongMessage="Host Name is required.";
        }else{
            newWrongMessage.hostnameWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.hostnameWrongMessage===""){
            $("#hostname").css({
                "border":"1px solid #999999",
            });
            return true;
        }else{
            $("#hostname").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    handleSubmit = (e) => {
        let self=this;
        e.preventDefault();
        this.props.form.validateFields((err, values) => {
            if (!err) {
                let hasWrongValue=false;
                if(self.checkHostname(values.hostname)===false){
                    hasWrongValue=true;
                    $("#hostname").focus();
                }
                if(hasWrongValue===true){
                    return;
                }


            }
        });
        
    }

    onClickCancel = () => {
        let self=this;
        self.props.form.resetFields();
        
    }


    render() {
        const {wrongMessage,enableClustering,dataTable,loading} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });

        let columns=[];
        columns.push({
            title:"NAME",
            dataIndex: 'name',
            key: 'name',
        });
        columns.push({
            title: "IP ADDRESS",
            dataIndex: 'ip_addr',
            key: 'ip_addr',
        });
        columns.push({
            title:"NETMASK",
            dataIndex: 'netmask',
            key: 'netmask',
        });
        columns.push({
            title:"VIP",
            dataIndex: 'vip',
            key: 'vip',
        });
        columns.push({
            title:"TYPE",
            dataIndex: 'type',
            key: 'type',
        });

        columns.push({
            title: 'SERVICES',
            dataIndex: 'services',
            key: 'services',
        });

        columns.push({
            title: "VLAN",
            dataIndex: 'vlan',
            key: 'vlan',
        });

        
        return (
            <div className="global-div-networksCtl">
            <Spin spinning={loading}>
                <div className="left-div-networksCtl">
                    <Guidance 
                        title={"Networks"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
                    />
                    <div className="img-div-networksCtl">
                       <img src={networksImg} className="img-img-networksCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-networksCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>
                    <div className="form-item-div-networksCtl">
                        <div className="form-item-title-div-networksCtl">
                            Host Name
                        </div>
                        <div className="form-item-input-div-networksCtl">
                            {getFieldDecorator('hostname', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckHostname.bind(self)}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-networksCtl" 
                        style={{display:wrongMessage.hostnameWrongMessage===""?"none":"block"}}>
                                {wrongMessage.hostnameWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="interfaces-div-networksCtl">
                        interfaces
                    </div>
                    <div className="enable-clustering-div-networksCtl">
                        <div className="enable-clustering-checkbox-div-networksCtl">
                            <Checkbox 
                                value={enableClustering}
                                onChange={self.onChangeCheckbox.bind(self)}
                            ></Checkbox>
                        </div>
                        <div className="enable-clustering-text-div-networksCtl">
                            Enable clustering
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="table-div-networksCtl">
                        <Table 
                            columns={columns} 
                            dataSource={dataTable} 
                            pagination={false}
                        />
                    </div>

                    <div className="form-button-div-networksCtl">
                        <div className="form-button-next-div-networksCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-networksCtl" 
                                htmlType="submit" 
                            >NEXT</Button>
                        </div>
                        <div className="form-button-cancel-div-networksCtl">
                            <Button 
                                className="form-button-cancel-antd-button-networksCtl" 
                                onClick={self.onClickCancel.bind(self)}
                            >CANCEL</Button>
                        </div>
                    </div>

                    </Form>


                    <div className="clear-float-div-common" ></div >
                </div>


                <div className="clear-float-div-common" ></div >
            </Spin>
            </div>
            
        )
    }
}


export default Form.create()(networksCtl);



