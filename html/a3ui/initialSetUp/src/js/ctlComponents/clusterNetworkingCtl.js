import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isIp,isPositiveInteger} from "../../libs/util";     
import '../../css/ctlComponents/clusterNetworkingCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/clusterNetworkingCtl";
import {i18n} from "../../i18n/ctlComponents/nls/clusterNetworkingCtl";

import networksImg from "../../media/networks.png";
import editNoImg from "../../media/editNo.png";
import editYesImg from "../../media/editYes.png";
import addVlanImg from "../../media/addVlan.png";
import removeVlanImg from "../../media/removeVlan.png";




const {Component} = React;

class clusterNetworkingCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                hostnameWrongMessage:"",
            },
            loading:false,
            dataTable:[],
            isEditing:false,
            originalDescription:"",
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

        let url= "/api/v1/configurator/cluster/networks";
         
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
            dataTable[i].key=dataTable[i].name;
            dataTable[i].clicked="";
            dataTable[i].services=dataTable[i].services.split(",");
        }
        self.setState({
            dataTable: dataTable,
            loading : false,
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
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#hostname").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    checkIpAddr=(ipAddr,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!ipAddr||ipAddr.toString().trim()===""){
            newWrongMessage.ipAddrWrongMessage="Ip Address is required.";
        }else
        if(isIp(ipAddr.toString().trim())===false){
            newWrongMessage.ipAddrWrongMessage="Ip Address format is incorret.";
        }else{
            newWrongMessage.ipAddrWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.ipAddrWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.ipAddrWrongMessage);
                newWrongMessage.ipAddrWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.ipAddrWrongMessage===""){
                $("#ip_addr").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#ip_addr").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }
    }

    checkNetmask=(netmask,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!netmask||netmask.toString().trim()===""){
            newWrongMessage.netmaskWrongMessage="Netmask is required.";
        }else
        if(isIp(netmask.toString().trim())===false){
            newWrongMessage.netmaskWrongMessage="Netmask format is incorret.";
        }else{
            newWrongMessage.netmaskWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.netmaskWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.netmaskWrongMessage);
                newWrongMessage.netmaskWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.netmaskWrongMessage===""){
                $("#netmask").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#netmask").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }
    }


    handleSubmit = (e) => {
        let self=this;
        e.preventDefault();
        this.props.form.validateFields((err, values) => {
            if (!err) {
                console.log(values);
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

    onClickText= (index,column) => {
        let self=this;
        
        if(self.state.isEditing===true){
            return;
        }
        let dataCopy=self.state.dataTable;
        dataCopy[index].clicked=column;
        self.setState({
            dataTable : dataCopy,
            originalDescription:dataCopy[index][column],
            isEditing:true,
        });
    }

    onEdit=(index,column,e) =>{
        let self=this;
        let dataCopy=self.state.dataTable;
        dataCopy[index][column]=e.target.value;
        
        self.setState({ 
            dataTable : dataCopy, 
        });

    }


    onClickEditOk= (index,column) => {
        let self=this;

        if(column==="ip_addr"&&self.checkIpAddr(self.state.dataTable[index].ip_addr,"table")===false){
            return;
        }
        if(column==="netmask"&&self.checkNetmask(self.state.dataTable[index].netmask,"table")===false){
            return;
        }

        let dataCopy=self.state.dataTable;
        dataCopy[index].clicked="";
        self.setState({
            dataTable : dataCopy,
            isEditing: false,
        }) 
    }

    onClickEditNo= (index,column) => {
        let self=this;

        let dataCopy=self.state.dataTable;
        dataCopy[index].clicked="";
        dataCopy[index][column]=self.state.originalDescription;
        self.setState({ 
            dataTable : dataCopy,
            isEditing:false,
        });
    }



    render() {
        const {wrongMessage,dataTable,loading} = this.state;
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
            render: (text, record, index) => {
                return (
                    text.indexOf("VLAN")===-1?
                    <div className="name-etho-div-clusterNetworkingCtl"  >
                        {text}
                    </div>
                    :
                    <div className="name-vlan-div-clusterNetworkingCtl">
                        <div className="name-vlan-blank-div-clusterNetworkingCtl">
                        </div>
                        <div className="name-vlan-text-div-clusterNetworkingCtl">
                            VLAN
                        </div>
                        <div className="name-text-div-clusterNetworkingCtl">
                            {text.slice(4)}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                );
            } 
        });
        columns.push({
            title: "IP ADDRESS",
            dataIndex: 'ip_addr',
            key: 'ip_addr',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="ip_addr"?
                            <div className=""  >
                                <div className="ipAddr-edit-input-div-clusterNetworkingCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"ip_addr")}
                                    />
                                </div>
                                <div className="ipAddr-edit-ok-div-clusterNetworkingCtl" onClick={self.onClickEditOk.bind(self,index,"ip_addr")}>
                                    <img className="ipAddr-edit-ok-img-clusterNetworkingCtl" src={editYesImg} />
                                </div>
                                <div className="ipAddr-edit-no-div-clusterNetworkingCtl" onClick={self.onClickEditNo.bind(self,index,"ip_addr")}>
                                    <img className="ipAddr-edit-no-img-clusterNetworkingCtl" src={editNoImg} />
                                </div>
                                <div className="clear-float-div-common" ></div >
                            </div>
                            :
                            <div className="ipAddr-text-div-clusterNetworkingCtl" onClick={self.onClickText.bind(self,index,"ip_addr")} >
                                {text}
                            </div>
                        }
                    </div>
                );
            } 
        });
        columns.push({
            title:"NETMASK",
            dataIndex: 'netmask',
            key: 'netmask',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="netmask"?
                            <div className=""  >
                                <div className="netmask-edit-input-div-clusterNetworkingCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"netmask")}
                                    />
                                </div>
                                <div className="netmask-edit-ok-div-clusterNetworkingCtl" onClick={self.onClickEditOk.bind(self,index,"netmask")}>
                                    <img className="netmask-edit-ok-img-clusterNetworkingCtl" src={editYesImg} />
                                </div>
                                <div className="netmask-edit-no-div-clusterNetworkingCtl" onClick={self.onClickEditNo.bind(self,index,"netmask")}>
                                    <img className="netmask-edit-no-img-clusterNetworkingCtl" src={editNoImg} />
                                </div>
                                <div className="clear-float-div-common" ></div >
                            </div>
                            :
                            <div className="netmask-text-div-clusterNetworkingCtl" onClick={self.onClickText.bind(self,index,"netmask")} >
                                {text}
                            </div>
                        }
                    </div>
                );
            } 
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
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            style={{ width: 110 }} 
                            disabled
                        >
                            <Option value="MANAGEMENT">Management</Option>
                            <Option value="REGISTRATION">Registration</Option>
                            <Option value="ISOLATION">Isolation</Option>
                            <Option value="NONE">None</Option>
                            <Option value="OTHER">Other</Option>
                        </Select>
                    </div>
                );
            } 
        });

        columns.push({
            title: 'SERVICES',
            dataIndex: 'services',
            key: 'services',
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            style={{ width: 110 }} 
                            mode="multiple"
                            disabled
                        >
                            <Option value="PORTAL">Portal</Option>
                            <Option value="RADIUS">Radius</Option>
                        </Select>
                    </div>
                );
            } 
        });
  
        return (
            <div className="global-div-clusterNetworkingCtl">
            <Spin spinning={loading}>
                <div className="left-div-clusterNetworkingCtl">
                    <Guidance 
                        title={"Networks"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
                    />
                    <div className="img-div-clusterNetworkingCtl">
                       <img src={networksImg} className="img-img-clusterNetworkingCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-clusterNetworkingCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>
                    <div className="form-item-div-clusterNetworkingCtl">
                        <div className="form-item-title-div-clusterNetworkingCtl">
                            Host Name
                        </div>
                        <div className="form-item-input-div-clusterNetworkingCtl">
                            {getFieldDecorator('hostname', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckHostname.bind(self)}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-clusterNetworkingCtl" 
                        style={{display:wrongMessage.hostnameWrongMessage===""?"none":"block"}}>
                                {wrongMessage.hostnameWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="interfaces-div-clusterNetworkingCtl">
                        interfaces
                    </div>

                    <div className="table-div-clusterNetworkingCtl">
                        <Table 
                            columns={columns} 
                            dataSource={dataTable} 
                            pagination={false}
                        />
                    </div>

                    <div className="form-button-div-clusterNetworkingCtl">
                        <div className="form-button-next-div-clusterNetworkingCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-clusterNetworkingCtl" 
                                htmlType="submit" 
                            >NEXT</Button>
                        </div>
                        <div className="form-button-cancel-div-clusterNetworkingCtl">
                            <Button 
                                className="form-button-cancel-antd-button-clusterNetworkingCtl" 
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


export default Form.create()(clusterNetworkingCtl);



