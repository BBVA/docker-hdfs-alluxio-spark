import org.rogach.scallop.ScallopConf

class Conf(arguments: Seq[String]) extends ScallopConf(arguments) {
  val spark = opt[String](required = true)
  val alluxio = opt[String](required = true)
  val out = opt[String](default = Some(alluxio + "_out.csv"))
  verify()
}