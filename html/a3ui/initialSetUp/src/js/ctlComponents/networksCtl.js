import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isIp,isPositiveInteger,isHostname} from "../../libs/util";     
import '../../css/ctlComponents/networksCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/networksCtl";
import {i18n} from "../../i18n/ctlComponents/nls/networksCtl";

import networksImg from "../../media/networks.svg";
import editNoImg from "../../media/editNo.png";
import editYesImg from "../../media/editYes.png";
import addVlanImg from "../../media/addVlan.png";
import removeVlanImg from "../../media/removeVlan.png";




const {Component} = React;

class networksCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                hostnameWrongMessage:"",
                nameWrongMessage:"",
                ipAddrWrongMessage:"",
                netmaskWrongMessage:"",
                vipWrongMessage:"",
            },
            enableClustering:true,
            loading:false,
            dataTable:[],
            isEditing:false,
            originalDescription:"",
            addVlanVisible:false,
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
        //     self.getTrueData(data);
        // });

        self.getTrueData(mock.networks);
    }

    getTrueData= (data) => {
        let self=this;
        let dataTable=data.items;
        for(let i=0;i<dataTable.length;i++){
            dataTable[i].key=dataTable[i].name;
            dataTable[i].vlan=dataTable[i].name;
            dataTable[i].clicked="";
            dataTable[i].services=dataTable[i].services.split(",");
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
        }else
        if(isHostname(hostname.toString().trim())===false){
            newWrongMessage.hostnameWrongMessage="invalid Host Name.";
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



    onBlurCheckName(e){
        let self=this;
        self.checkName(e.target.value);
    }

    checkName=(name,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!name||name.toString().trim()===""){
            newWrongMessage.nameWrongMessage="Name is required.";
        }else
        if(isPositiveInteger(name.toString().trim())===false){
            newWrongMessage.nameWrongMessage="The value must be a positive number.";
        }else{
            newWrongMessage.nameWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.nameWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.nameWrongMessage);
                newWrongMessage.nameWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.nameWrongMessage===""){
                $("#name").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#name").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }



    }

    onBlurCheckIpAddr(e){
        let self=this;
        self.checkIpAddr(e.target.value);
    }

    checkIpAddr=(ipAddr,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!ipAddr||ipAddr.toString().trim()===""){
            newWrongMessage.ipAddrWrongMessage="IP address is required.";
        }else
        if(isIp(ipAddr.toString().trim())===false){
            newWrongMessage.ipAddrWrongMessage="IP address format is incorrect.";
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

    onBlurCheckNetmask(e){
        let self=this;
        self.checkNetmask(e.target.value);
    }

    checkNetmask=(netmask,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!netmask||netmask.toString().trim()===""){
            newWrongMessage.netmaskWrongMessage="Netmask is required.";
        }else
        if(isIp(netmask.toString().trim())===false){
            newWrongMessage.netmaskWrongMessage="Netmask format is incorrect.";
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


    onBlurCheckVip(e){
        let self=this;
        self.checkVip(e.target.value);
    }

    checkVip=(vip,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!vip||vip.toString().trim()===""){
            newWrongMessage.vipWrongMessage="VIP is required.";
        }else
        if(isIp(vip.toString().trim())===false){
            newWrongMessage.vipWrongMessage="VIP format is incorrect.";
        }else{
            newWrongMessage.vipWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.vipWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.vipWrongMessage);
                newWrongMessage.vipWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.vipWrongMessage===""){
                $("#vip").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#vip").css({
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
        if(column==="name"){
            dataCopy[index][column]="VLAN"+e.target.value;
        }else{
            dataCopy[index][column]=e.target.value;
        }
        
        self.setState({ 
            dataTable : dataCopy, 
        });

    }

    onChangeSelect=(index,column,value) =>{
        let self=this;
        let dataCopy=self.state.dataTable;
        dataCopy[index][column]=value;
        self.setState({ 
            dataTable : dataCopy, 
        });

    }


    onClickEditOk= (index,column) => {
        let self=this;

        if(column==="name"&&self.checkName(self.state.dataTable[index].name.slice(4),"table")===false){
            return;
        }
        if(column==="ip_addr"&&self.checkIpAddr(self.state.dataTable[index].ip_addr,"table")===false){
            return;
        }
        if(column==="netmask"&&self.checkNetmask(self.state.dataTable[index].netmask,"table")===false){
            return;
        }
        if(column==="vip"&&self.checkVip(self.state.dataTable[index].vip,"table")===false){
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

    onClickAddVlan= (index) => {
        let self=this;
        self.props.form.setFieldsValue({
            name:"",
            ip_addr:"",
            netmask:"",
            vip:"",
            type:"MANAGEMENT",
            services:["PORTAL"],

        })
        $("#name,#ip_addr,#netmask,#vip").css({
            "border":"1px solid #d9d9d9",
        });
        let wrongMessageCopy=self.state.wrongMessage;
        wrongMessageCopy.nameWrongMessage="";
        wrongMessageCopy.ipAddrWrongMessage="";
        wrongMessageCopy.netmaskWrongMessage="";
        wrongMessageCopy.vipWrongMessage="";
        self.setState({ 
            addVlanVisible:true,
        });

    }


    onOkAddVlan = (e) => {
        let self=this;
        e.preventDefault();
        this.props.form.validateFields((err, values) => {
            if (!err) {

                console.log(values);

                let hasWrongValue=false;
                if(self.checkVip(values.vip)===false){
                    hasWrongValue=true;
                    $("#vip").focus();
                }
                if(self.checkNetmask(values.netmask)===false){
                    hasWrongValue=true;
                    $("#netmask").focus();
                }
                if(self.checkIpAddr(values.ip_addr)===false){
                    hasWrongValue=true;
                    $("#ip_addr").focus();
                }
                if(self.checkName(values.name)===false){
                    hasWrongValue=true;
                    $("#name").focus();
                }
                if(hasWrongValue===true){
                    return;
                }

                self.setState({ 
                    addVlanVisible:false,
                });


            }
        });
        
    }


    onCancelAddVlan= () => {
        let self=this;
        self.setState({ 
            addVlanVisible:false,
        });

    }

    onClickRemoveVlan= (index) => {
        let self=this;
        Modal.confirm({
            content: "Are you sure you want to do this?",
            okText: 'Yes',
            cancelText: 'No',
            onOk() {
                let dataCopy=self.state.dataTable;
                dataCopy.splice(index,1);
                self.setState({ 
                    dataTable : dataCopy,
                });
            },
            onCancel() {},
        });

    }


    render() {
        const {wrongMessage,enableClustering,dataTable,loading,addVlanVisible} = this.state;
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
                let numberHtml;
                if(dataTable[index].clicked==="name"){
                    numberHtml=
                        <div className="name-edit-div-networksCtl"  >
                            <div className="name-edit-input-div-networksCtl">
                                <Input
                                    value={text.slice(4)}
                                    autoFocus
                                    onChange={self.onEdit.bind(self,index,"name")}
                                />
                            </div>
                            <div className="name-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"name")}>
                                <img className="name-edit-ok-img-networksCtl" src={editYesImg} />
                            </div>
                            <div className="name-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"name")}>
                                <img className="name-edit-no-img-networksCtl" src={editNoImg} />
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                }else{
                    numberHtml=
                        <div className="name-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"name")} >
                            {text.slice(4)}
                        </div>
                }


                return (
                    text.indexOf("VLAN")===-1?
                    <div className="name-etho-div-networksCtl"  >
                        {text}
                    </div>
                    :
                    <div className="name-vlan-div-networksCtl">
                        <div className="name-vlan-blank-div-networksCtl">
                        </div>
                        <div className="name-vlan-text-div-networksCtl">
                            VLAN
                        </div>
                        {numberHtml}
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
                                <div className="ipAddr-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"ip_addr")}
                                    />
                                </div>
                                <div className="ipAddr-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"ip_addr")}>
                                    <img className="ipAddr-edit-ok-img-networksCtl" src={editYesImg} />
                                </div>
                                <div className="ipAddr-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"ip_addr")}>
                                    <img className="ipAddr-edit-no-img-networksCtl" src={editNoImg} />
                                </div>
                                <div className="clear-float-div-common" ></div >
                            </div>
                            :
                            <div className="ipAddr-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"ip_addr")} >
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
                                <div className="netmask-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"netmask")}
                                    />
                                </div>
                                <div className="netmask-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"netmask")}>
                                    <img className="netmask-edit-ok-img-networksCtl" src={editYesImg} />
                                </div>
                                <div className="netmask-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"netmask")}>
                                    <img className="netmask-edit-no-img-networksCtl" src={editNoImg} />
                                </div>
                                <div className="clear-float-div-common" ></div >
                            </div>
                            :
                            <div className="netmask-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"netmask")} >
                                {text}
                            </div>
                        }
                    </div>
                );
            } 
        });

        if(enableClustering===true){
            columns.push({
                title:"VIP",
                dataIndex: 'vip',
                key: 'vip',
                render: (text, record, index) => {
                    return (
                        <div>
                            {
                                dataTable[index].clicked==="vip"?
                                <div className=""  >
                                    <div className="vip-edit-input-div-networksCtl">
                                        <Input
                                            value={text}
                                            autoFocus
                                            onChange={self.onEdit.bind(self,index,"vip")}
                                        />
                                    </div>
                                    <div className="vip-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"vip")}>
                                        <img className="vip-edit-ok-img-networksCtl" src={editYesImg} />
                                    </div>
                                    <div className="vip-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"vip")}>
                                        <img className="vip-edit-no-img-networksCtl" src={editNoImg} />
                                    </div>
                                    <div className="clear-float-div-common" ></div >
                                </div>
                                :
                                <div className="vip-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"vip")} >
                                    {text}
                                </div>
                            }
                        </div>
                    );
                } 
            });
        }

        columns.push({
            title:"TYPE",
            dataIndex: 'type',
            key: 'type',
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            onChange={self.onChangeSelect.bind(self,index,"type")}
                            style={{ width: 110 }} 
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
                            onChange={self.onChangeSelect.bind(self,index,"services")}
                            style={{ width: 110 }} 
                            mode="multiple"
                        >
                            <Option value="PORTAL">Portal</Option>
                            <Option value="RADIUS">RADIUS</Option>
                        </Select>
                    </div>
                );
            } 
        });

        columns.push({
            title: "VLAN",
            dataIndex: 'vlan',
            key: 'vlan',
            render: (text, record, index) => {
                return (
                    text.indexOf("VLAN")===-1?
                    <div className="vlan-add-div-networksCtl" onClick={self.onClickAddVlan.bind(self,index)}  >
                        <div className="vlan-add-img-div-networksCtl">
                            +
                        </div>
                        <div className="vlan-add-text-div-networksCtl">
                            Add VLAN
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                    :
                    <div className="vlan-remove-div-networksCtl" onClick={self.onClickRemoveVlan.bind(self,index)}  >
                        <div className="vlan-remove-img-div-networksCtl">
                            x
                        </div>
                        <div className="vlan-remove-text-div-networksCtl">
                            Remove VLAN
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                );
            } 
        });

        
        return (
            <div className="global-div-networksCtl">
            <Spin spinning={loading}>
                <div className="left-div-networksCtl">
                    <Guidance 
                        title={"Instructions"} 
                        content={["On this page, you can configure the network interfaces detected on your system.","Don't worry, you can always come back to this step if you change your mind.","Enable all the physical interfaces you want to use for A3. If you use VLAN enforcement, specify which VLAN is dedicated to your registration, isolation, and management subnets. You must always have at least one management subnet."]} 
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
                                checked={enableClustering}
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

                <Modal 
                    title="Add VLAN"
                    visible={addVlanVisible}
                    width={302}
                    footer={null}
                    onCancel={self.onCancelAddVlan.bind(self)}
                >
         
                    <div className="modal-div-networksCtl">
                        
                        <Form onSubmit={self.onOkAddVlan.bind(self)}>
                        <div className="modal-form-item-div-networksCtl" style={{marginTop:"0px"}}>
                            <div className="modal-form-item-title-div-networksCtl">
                                Name
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                <div className="modal-form-item-name-vlan-div-networksCtl">
                                    VLAN
                                </div>
                                <div className="modal-form-item-name-number-div-networksCtl">
                                    {getFieldDecorator('name', {
                                        rules: [],
                                    })(
                                        <Input 
                                        style={{height:"32px"}}
                                        onBlur={self.onBlurCheckName.bind(self)}
                                        />
                                    )}
                                </div>
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.nameWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.nameWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>


                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                Ip Address
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('ip_addr', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckIpAddr.bind(self)}
                                    
                                    />
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.ipAddrWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.ipAddrWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>

                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                Netmask
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('netmask', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckNetmask.bind(self)}
                                    
                                    />
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.netmaskWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.netmaskWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>

                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                Vip
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('vip', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckVip.bind(self)}
                                    
                                    />
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.vipWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.vipWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>


                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                Type
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('type', {
                                    rules: [],
                                    initialValue:"MANAGEMENT",
                                })(

                                    <Select 
                                        option={{initialValue:"MANAGEMENT"}}
                                        style={{ height: 32 }} 
                                    >
                                        <Option value="MANAGEMENT" >Management</Option>
                                        <Option value="REGISTRATION">Registration</Option>
                                        <Option value="ISOLATION" >Isolation</Option>
                                        <Option value="NONE" >None</Option>
                                        <Option value="OTHER" >Other</Option>
                                    </Select>

                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl">
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                Services
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('services', {
                                    rules: [],
                                    initialValue:["PORTAL"],
                                })(
                                    <Select 
                                        mode="multiple"
                                        style={{ height: 32 }} 
                                    >
                                        <Option value="PORTAL">Portal</Option>
                                        <Option value="RADIUS">RADIUS</Option>
                                    </Select>
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl">
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="modal-form-button-div-networksCtl">
                            <div className="modal-form-button-next-div-networksCtl">
                                <Button 
                                    type="primary" 
                                    className="modal-form-button-next-antd-button-networksCtl" 
                                    htmlType="submit" 
                                >NEXT</Button>
                            </div>
                            <div className="modal-form-button-cancel-div-networksCtl">
                                <Button 
                                    className="modal-form-button-cancel-antd-button-networksCtl" 
                                    onClick={self.onCancelAddVlan.bind(self)}
                                >CANCEL</Button>
                            </div>
                        </div>
                        </Form>


                
                        <div className="clear-float-div-common" ></div >
                    </div>
            
                </Modal>
                <div className="clear-float-div-common" ></div >
            </Spin>


            
            </div>
            
        )
    }
}


export default Form.create()(networksCtl);



