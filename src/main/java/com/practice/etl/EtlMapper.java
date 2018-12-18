package com.practice.etl;

import com.practice.etl.util.EtlUtil;
import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

/**
 * @author qxy
 */
public class EtlMapper extends Mapper<LongWritable,Text,Text,NullWritable> {

    private Text text = new Text();

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String etl = EtlUtil.etl(value.toString());
        if(StringUtils.isNotEmpty(etl)) {
            text.set(etl);
            context.write(text,NullWritable.get());
        }
    }
}
