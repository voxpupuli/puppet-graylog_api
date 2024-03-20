# @summary custom type for graylog_api pipeline stage loose
#
type Graylog_api::Pipeline::Stage::Loose = Variant[
  Graylog_api::Pipeline::Stage,
  Array[String,1],
  String,
]
