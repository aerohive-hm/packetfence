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

import editNoImg from "../../media/editNo.svg";
import editYesImg from "../../media/editYes.svg";

import networksImg from "../../media/networks.svg";




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

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/cluster/networks";
         
        let param={
        }
        
        self.setState({
            loading : true,
        })

        new RequestApi('get',url,param,xCsrfToken,(data)=>{
            self.getTrueData(data);
        });

        //self.getTrueData(mock.networks);
    }

    getTrueData= (data) => {
        let self=this;
        let dataTable=data.items;
        for(let i=0;i<dataTable.length;i++){
            dataTable[i].key=dataTable[i].name;
            dataTable[i].clicked="";
            dataTable[i].services=dataTable[i].services===""?[]:dataTable[i].services.split(",");
        }
        self.setState({
            dataTable: dataTable,
            loading : false,
        }); 
        self.props.form.resetFields();
        self.props.form.setFieldsValue({
            hostname:data.hostname,
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
            newWrongMessage.hostnameWrongMessage=self.state.i18n.hostNameIsRequired;
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
            newWrongMessage.ipAddrWrongMessage=self.state.i18n.iPAddressIsRequired;
        }else
        if(isIp(ipAddr.toString().trim())===false){
            newWrongMessage.ipAddrWrongMessage=self.state.i18n.iPAddressFormatIsIncorrect;
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
            newWrongMessage.netmaskWrongMessage=self.state.i18n.netmaskIsRequired;
        }else
        if(isIp(netmask.toString().trim())===false){
            newWrongMessage.netmaskWrongMessage=self.state.i18n.netmaskFormatIsIncorrect;
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

    getItems= () => {
        let self=this;
        let items=[];
        for(let i=0;i<self.state.dataTable.length;i++){
            items.push({
                id:self.state.dataTable[i].id,
                name:self.state.dataTable[i].name,
                ip_addr:self.state.dataTable[i].ip_addr,
                netmask:self.state.dataTable[i].netmask,
                vip:self.state.dataTable[i].vip,
                type:self.state.dataTable[i].type,
                services:self.state.dataTable[i].services.join(","),
            });
        }
        return items;
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

                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/cluster/networks";
                
                let param={
                    hostname:values.hostname,
                    items:self.getItems(),
                }

                new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.props.changeStatus("joining");
                    }else{
                        message.destroy();
                        message.error(data.msg);
                    }

                }) 

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


        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/interface";

        let dataCopy=self.state.dataTable;
        
        let param={
            "name":dataCopy[index].name,
            "ip_addr":dataCopy[index].ip_addr,
            "netmask":dataCopy[index].netmask,
            "vip":dataCopy[index].vip,
            "type":dataCopy[index].type,
            "services":dataCopy[index].services.join(","),
        }

        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                dataCopy[index].clicked="";
                self.setState({
                    dataTable : dataCopy,
                    isEditing: false,
                }) 
            }else{
                message.destroy();
                message.error(data.msg);
            }

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
            title:self.state.i18n.name,
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
            title: self.state.i18n.ipAddress,
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
            title:self.state.i18n.netmask,
            dataIndex: 'netmask',
            key: 'netmask',
        });
        columns.push({
            title:self.state.i18n.vip,
            dataIndex: 'vip',
            key: 'vip',
        });
        columns.push({
            title:self.state.i18n.type,
            dataIndex: 'type',
            key: 'type',
            render: (text, record, index) => {
                let typeObject={
                    MANAGEMENT:self.state.i18n.management,
                    REGISTRATION:self.state.i18n.registration,
                    ISOLATION:self.state.i18n.isolation,
                    NONE:self.state.i18n.none,
                    OTHER:self.state.i18n.other,
                    PORTAL:self.state.i18n.portal,
                }
                return (
                    <div>
                        {typeObject[text]}
                    </div>
                );
            } 
        });

        columns.push({
            title: self.state.i18n.services,
            dataIndex: 'services',
            key: 'services',
            render: (text, record, index) => {
                let servicesObject={
                    PORTAL:self.state.i18n.portal,
                    RADIUS:self.state.i18n.radius,
                }
                let servicesHtml="";
                for(let i=0;i<text.length;i++){
                    if(i===0){
                        servicesHtml=servicesHtml+servicesObject[text[i]];
                    }else{
                        servicesHtml=servicesHtml+", "+servicesObject[text[i]];
                    }
                }
                return (
                    <div>
                        {servicesHtml}
                    </div>
                );
            } 
        });
  
        return (
            <div className="global-div-clusterNetworkingCtl">
            <Spin spinning={loading}>
                <div className="left-div-clusterNetworkingCtl">
                    <Guidance 
                        title={self.state.i18n.networks} 
                        content={[self.state.i18n.networksMessage]} 
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
                            {self.state.i18n.hostName}
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
                        {self.state.i18n.interfaces}
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
                            >{self.state.i18n.next}</Button>
                        </div>
                        <div className="form-button-cancel-div-clusterNetworkingCtl">
                            <Button 
                                className="form-button-cancel-antd-button-clusterNetworkingCtl" 
                                onClick={self.onClickCancel.bind(self)}
                            >{self.state.i18n.cancel}</Button>
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



