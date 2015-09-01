#include <ruby.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

// The one and only lookup table.
int HR[32487834];
const char * const HAND_CATEGORY_KEYS[] = { "invalid_hand", "high_card", "one_pair", "two_pairs", "three_of_a_kind", "straight", "flush", "full_house", "four_of_a_kind", "straight_flush" };

char* get_path_from_ruby(){
  VALUE cHandRank = rb_const_get(rb_cObject, rb_intern("HandRank"));
  ID sym_mymodule = rb_intern( "HOME" );
  VALUE home = rb_const_get( cHandRank, sym_mymodule );
  return StringValueCStr( home );
}

char* concat( char* first, char* second ){
  size_t first_length = strlen( first );
  size_t second_length = strlen( second );
  int both_length = first_length + second_length + 1;
  char* both = (char*) malloc( both_length * sizeof( char ));

  strcpy( both, first );
  strcat( both, second );

  return both;
}

char* with_path( char* file_name ){
  char* path = get_path_from_ruby();

  return concat( path, file_name );
}

char* hand_category_key( int index ){
  size_t length = strlen( HAND_CATEGORY_KEYS[ index ]);
  char* name = (char*) malloc( length * sizeof( char ));

  strcpy( name, HAND_CATEGORY_KEYS[ index ]);

  return name;
}

char* c_hand_category_key( int index ){
  size_t length = strlen( HAND_CATEGORY_KEYS[ index ]);
  char* key = (char*) malloc( length * sizeof( char ));

  strcpy( key, HAND_CATEGORY_KEYS[ index ]);

  return key;
}

void convert_ruby_array_to_c_array( VALUE rb_cards, int *c_cards, int length ){
  int i = 0;

  for( int i = 0; i < length; i++ ){
    c_cards[ i ] = NUM2INT( rb_ary_entry( rb_cards, i ));
  }
}

int c_rank_7_card_hand( int* cards ){
  int p = HR[53 + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  return p;
}

int c_rank_6_card_hand( int* cards ){
  int p = HR[53 + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  return HR[p];
}

int c_rank_5_card_hand( int* cards ){
  int p = HR[53 + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  return HR[p];
}

void load_lut(){
  memset( HR, 0, sizeof( HR ));

  FILE * fin = fopen( with_path("ranks.data"), "rb" );

  if( fin == NULL ){
    rb_raise( rb_eIOError, "could not open data file.");
    exit(1);
  }

  // Load the HANDRANKS.DAT file data into the HR array
  size_t bytesread = fread( HR, sizeof( HR ), 1, fin );
  fclose( fin );
}

VALUE rb_get( VALUE klass, VALUE rb_cards ){
  int length = RARRAY_LEN( rb_cards );
  int c_cards[ length ];
  int result;

  convert_ruby_array_to_c_array( rb_cards, c_cards, length );

  switch( length ){
    case 5 :
       result = c_rank_5_card_hand( c_cards );
       break;
    case 6 :
       result = c_rank_6_card_hand( c_cards );
       break;
    default :
       result = c_rank_7_card_hand( c_cards );
  }

  return INT2NUM( result );
}

VALUE rb_category( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int category = rank >> 12;

  return INT2NUM( category );
}

VALUE rb_rank_in_category( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int rank_in_category = rank & 0x00000FFF;

  return INT2NUM( rank_in_category );
}

VALUE rb_category_key( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int category = rank >> 12;
  
  char* key = c_hand_category_key( category );

  return rb_str_new2( key );
}

VALUE rb_explain( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int category = rank >> 12;
  int rank_in_category = rank & 0x00000FFF;
  VALUE category_key = rb_category_key( klass, rb_rank );
  VALUE name = rb_str_gsub( category_key, rb_str_new2( "_" ), rb_str_new2( " " ));

  VALUE result = rb_sprintf( "The hand is a %"PRIsVALUE"\nRank: %d Category: %d Rank in category: %d", name, rank, category, rank_in_category );

  return result;
}

void Init_hand_rank( void ){

  load_lut();

  VALUE cHandRank = rb_const_get(rb_cObject, rb_intern("HandRank"));

  rb_define_singleton_method( cHandRank, "get", rb_get, 1 );
  rb_define_singleton_method( cHandRank, "category", rb_category, 1 );
  rb_define_singleton_method( cHandRank, "rank_in_category", rb_rank_in_category, 1 );
  rb_define_singleton_method( cHandRank, "category_key", rb_category_key, 1 );
  rb_define_singleton_method( cHandRank, "explain", rb_explain, 1 );
}