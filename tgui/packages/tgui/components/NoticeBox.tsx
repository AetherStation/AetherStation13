/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { Box, BoxProps } from './Box';

type Props = ExclusiveProps & BoxProps;

/** You MUST use only one or none */
type NoticeType = 'info' | 'success' | 'danger' | 'warning';

type None = {
  [K in NoticeType]?: undefined;
};

type ExclusiveProps =
  | None
  | (Omit<None, 'info'> & {
      info: boolean;
    })
  | (Omit<None, 'success'> & {
      success: boolean;
    })
  | (Omit<None, 'danger'> & {
      danger: boolean;
    })
  | (Omit<None, 'warning'> & {
    warning: boolean;
    });

export function NoticeBox(props: Props) {
  const { className, color, info, success, danger, warning, ...rest } = props;

  return (
    <Box
      className={classes([
        'NoticeBox',
        color && 'NoticeBox--color--' + color,
        info && 'NoticeBox--type--info',
        success && 'NoticeBox--type--success',
        danger && 'NoticeBox--type--danger',
        warning && 'NoticeBox--type--warning',
        className,
      ])}
      {...rest}
    />
  );
}
