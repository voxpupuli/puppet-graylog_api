type Graylog_api::Pipeline::Stage = Struct[{
    match => Enum['all','either', 'pass'],
    rules => Array[String,1],
}]
