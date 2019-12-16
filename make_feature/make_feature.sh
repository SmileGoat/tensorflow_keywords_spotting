# Copyright 2019 PEACH LAB. All Rights Reserved.
# Author: goat.zhou@foxmail.com

expt_dir=/home/goat/experiments/exp
train_cmd="run.pl"

. ./cmd.sh
. ./path.sh
. utils/parse_options.sh


mkdir -p $expt_dir
feature_dir=$expt_dir

# pipeline steps control options
prep_fbank=1
lang=/home/goat/resource/align_resource
align_model_dir=/home/goat/resource/align_resource

njobs=10
fbank_config=common/config/fbank.conf
pitch_config=common/config/pitch.conf
hotword_align_config=common/config/align.params

dict=$align_model/dict

if [ -e $expt_dir/data/.done_split_data ] ; then
  echo "split data is already done, skip it "
else
  ./local/prep_data.sh --task train --per_utt 0\
    --pipeline_folder $expt_dir --dict_file $dict \
    --data_transcript_file $expt_dir/data/transcript_train
  ./local/prep_data.sh --task dev --per_utt 0\
    --pipeline_folder $expt_dir --dict_file $dict \
    --data_transcript_file $expt_dir/data/transcript_dev
  if [ -e $expt_dir/data/transcript_test ] ; then
    ./local/prep_data.sh --task test --per_utt 0\
      --pipeline_folder $expt_dir --dict_file $dict \
      --data_transcript_file $expt_dir/data/transcript_test
  fi

  touch $expt_dir/data/.done_split_data
fi

srcdata=$expt_dir
data=$expt_dir/data
data_fbank=$expt_dir/data-fbank
if [ -e $data_fbank/.done_prep_fbank ] ; then
  echo "prep fbank is already done, skip it"
else
  if [ -e $srcdata/data/transcript_train ]; then
    mkdir -p $data_fbank/train
    cp $data/train/* $data_fbank/train/;
  fi
  if [ -e $srcdata/data/transcript_dev ]; then
    mkdir -p $data_fbank/dev
    cp $data/dev/* $data_fbank/dev/;
  fi
  if [ -e $srcdata/data/transcript_test ]; then
    mkdir -p $data_fbank/test
    cp $data/test/* $data_fbank/test/;
  fi

  if [ -e $srcdata/data/transcript_train ]; then
    steps/make_fbank.sh --cmd "$train_cmd" --nj $njobs --fbank-config $fbank_config \
      $data_fbank/train  $data_fbank/train/_log $data_fbank/train/_data
    utils/fix_data_dir.sh $data_fbank/train
    steps/compute_cmvn_stats.sh $data_fbank/train \
      $data_fbank/train/_log $data_fbank/train/_data || exit 1
  fi

  if [ -e $srcdata/data/transcript_dev ]; then
    steps/make_fbank.sh --cmd "$train_cmd" --nj $njobs --fbank-config $fbank_config \
      $data_fbank/dev $data_fbank/dev/_log $data_fbank/dev/_data
    utils/fix_data_dir.sh $data_fbank/dev
    steps/compute_cmvn_stats.sh $data_fbank/dev \
      $data_fbank/dev/_log $data_fbank/dev/_data || exit 1
  fi

  if [ -e $srcdata/data/transcript_test ]; then
    steps/make_fbank.sh --cmd "$train_cmd" --nj $njobs --fbank-config $fbank_config \
      $data_fbank/test $data_fbank/test/_log $data_fbank/test/_data
    utils/fix_data_dir.sh $data_fbank/test
    steps/compute_cmvn_stats.sh $data_fbank/test \
      $data_fbank/test/_log $data_fbank/test/_data || exit 1
  fi
  touch $data_fbank/.done_prep_fbank
fi

data_fbank_pitch=$expt_dir/data-fbank-pitch

if [ -e $data_fbank_pitch/.done_prep_fbank_pitch ] ; then
  echo "prep fbank is already done, skip it"
else
  if [ -e $srcdata/data/transcript_train ]; then
    mkdir -p $data_fbank_pitch/train
    cp $data/train/* $data_fbank_pitch/train/;
  fi
  if [ -e $srcdata/data/transcript_dev ]; then
    mkdir -p $data_fbank_pitch/dev
    cp $data/dev/* $data_fbank_pitch/dev/;
  fi
  if [ -e $srcdata/data/transcript_test ]; then
    mkdir -p $data_fbank_pitch/test
    cp $data/test/* $data_fbank_pitch/test/;
  fi

  if [ -e $srcdata/data/transcript_train ]; then
    steps/make_fbank_pitch.sh --cmd "$train_cmd" --nj $njobs --fbank-config $fbank_config --pitch_config $pitch_config \
      $data_fbank_pitch/train  $data_fbank_pitch/train/_log $data_fbank_pitch/train/_data
    utils/fix_data_dir.sh $data_fbank_pitch/train
    steps/compute_cmvn_stats.sh $data_fbank_pitch/train \
      $data_fbank_pitch/train/_log $data_fbank_pitch/train/_data || exit 1
  fi

  if [ -e $srcdata/data/transcript_dev ]; then
    steps/make_fbank_pitch.sh --cmd "$train_cmd" --nj $njobs --fbank-config $fbank_config --pitch_config $pitch_config \
      $data_fbank_pitch/dev $data_fbank_pitch/dev/_log $data_fbank_pitch/dev/_data
    utils/fix_data_dir.sh $data_fbank_pitch/dev
    steps/compute_cmvn_stats.sh $data_fbank_pitch/dev \
      $data_fbank_pitch/dev/_log $data_fbank_pitch/dev/_data || exit 1
  fi

  if [ -e $srcdata/data/transcript_test ]; then
    steps/make_fbank_pitch.sh --cmd "$train_cmd" --nj $njobs --fbank-config $fbank_config --pitch_config $pitch_config \
      $data_fbank_pitch/test $data_fbank_pitch/test/_log $data_fbank_pitch/test/_data
    utils/fix_data_dir.sh $data_fbank_pitch/test
    steps/compute_cmvn_stats.sh $data_fbank_pitch/test \
      $data_fbank_pitch/test/_log $data_fbank_pitch/test/_data || exit 1
  fi
  touch $data_fbank_pitch/.done_prep_fbank_pitch
fi



align_dir=$srcdata/exp/
if [ -e $align_dir/.done_train_align ] ; then
  echo "prep alignment is already done, skip it"
else
  if [ -e $srcdata/data/transcript_train ]; then
    steps/nnet3/goat_align.sh --nj $njobs --cmd "$train_cmd" \
      $data_fbank_pitch/train $lang \
      $align_model_dir $align_dir/train_align || exit 1;
      gunzip -c $align_dir/train_align/ali.*gz > $align_dir/train_align/ali.ark
  fi
  if [ -e $srcdata/data/transcript_dev ]; then
    steps/nnet3/goat_align.sh --nj $njobs --cmd "$train_cmd" \
      $data_fbank_pitch/dev $lang \
      $align_model_dir $align_dir/dev_align || exit 1;
    gunzip -c $align_dir/dev_align/ali.*gz > $align_dir/dev_align/ali.ark
  fi
  touch $align_dir/.done_train_align
fi

#hotword_align
hotword_align_cmd=state2howtword_sequences
if [ -e $align_dir/.done_hotword_align ] ; then
  echo "hotword alignment is already done, skip it"
else
  if [ -e $srcdata/data/transcript_train ]; then
    input_rspecifier="ark:$align_dir/train_align/ali.ark"
    output_wspecifier="ark,t:$align_dir/train_align/hotword.ali.train.ark"

    $hotword_align_cmd \
      --model_name=$align_dir/train_align/final.mdl \
      --phone_symbol_table_file=$lang/phones.txt \
      --config_file=$hotword_align_config \
      --generate_htk_label_file=false \
      --alignments_rspecifier="$input_rspecifier" \
      --char_wspecifier="$output_wspecifier"
    analyze-counts --binary=false "$output_wspecifier" $align_dir/train_align/ali_train_hotword.counts
  fi

  if [ -e $srcdata/data/transcript_dev ]; then
    input_rspecifier="ark:$align_dir/dev_align/ali.ark"
    output_wspecifier="ark,t:$align_dir/dev_align/hotword.ali.dev.ark"

    $hotword_align_cmd \
      --model_name=$align_dir/train_align/final.mdl \
      --phone_symbol_table_file=$lang/phones.txt \
      --config_file=$hotword_align_config \
      --generate_htk_label_file=false \
      --alignments_rspecifier="$input_rspecifier" \
      --char_wspecifier="$output_wspecifier"
    touch $align_dir/.done_hotword_align
  fi
fi

