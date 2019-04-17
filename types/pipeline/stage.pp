type Graylog_api::Pipeline::Stage = Struct[{
    match => Enum['all','either'],
    rules => Array[String,1],
}]
