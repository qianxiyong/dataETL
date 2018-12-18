package com.practice.etl;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * @author qxy
 * 用于数据清洗的mapreduce
 * 没有reduce所以设置reduce任务数为0
 */
public class EtlTool implements Tool {

    private Configuration conf;

    public int run(String[] strings) throws Exception {

        Job job = Job.getInstance(getConf());
        job.setJobName("EtlData");
        job.setJarByClass(EtlTool.class);

        job.setMapperClass(EtlMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(NullWritable.class);
        job.setNumReduceTasks(0);
        FileInputFormat.addInputPath(job,new Path("/guili/video/video"));
        FileOutputFormat.setOutputPath(job,new Path("/output"));

        boolean completion = job.waitForCompletion(true);
        if(completion) {
            return 0;
        }
        return 1;
    }

    public void setConf(Configuration configuration) {
        this.conf = configuration;
    }

    public Configuration getConf() {
        return this.conf;
    }

    public static void main(String[] args) {
        try {
            int result = ToolRunner.run(new EtlTool(), args);
            if(result == 0) {
                System.out.println("运行成功");
            } else {
                System.out.println("运行失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
